define (require) ->

	Producer = require 'datacommunication/producers/Producer'
	Q = require 'lib/q'
	QueryKeys = require 'datacommunication/QueryKeys'
	SubscriptionKeys = require 'datacommunication/SubscriptionKeys'
	GroupsRepository = require 'datacommunication/repositories/groups/GroupsRepository'
	LocalStorageRepository = require 'datacommunication/repositories/localstorage/LocalStorageRepository'

	class NavigationProducer extends Producer

		constructor: ->
			LocalStorageRepository.on 'change:key_punter_setting', @_onKeyPunterSettingChange
			super

		# ------------------------------------------------------------------------------------------------
		query: (queryKey, options) ->
			deferred = Q.defer()

			switch queryKey
				when QueryKeys.HIGHLIGHTED_GROUPS
					Q.all [
						LocalStorageRepository.queryPunterSettings()
						GroupsRepository.queryHighlightedGroups()
					]
					.then (results) =>
						deferred.resolve @_buildHighlightedGroupsData(results)

					return deferred.promise

				else
					throw new Error("Unknown query queryKey: #{queryKey}")
		# ------------------------------------------------------------------------------------------------

		_buildHighlightedGroupsData: (results) ->
			groupsFromLocalStorage = results[0]?.navigation?.leagues or []
			highlightedGroups = results[1]
			modifiedData = []
			reverse = true
			separator = ' / '
			skipFirst = true

			for groupId in groupsFromLocalStorage
				group = GroupsRepository.getGroupById(groupId)
				if group
					highlightedGroups.push group

			for model in highlightedGroups
				model = model.toJSON()
				eventPath = GroupsRepository.getLocalizedGroupPathById model.id, separator, reverse, skipFirst
				model.eventPath = eventPath
				modifiedData.push model

			return modifiedData

		# ------------------------------------------------------------------------------------------------
		_onKeyPunterSettingChange: (localStorageModel) =>
			@query(QueryKeys.HIGHLIGHTED_GROUPS).then (highlightedGroups) =>
				@produce SubscriptionKeys.HIGHLIGHTED_GROUPS_CHANGE, highlightedGroups
		# ------------------------------------------------------------------------------------------------


	# ----------------------------------------------------------------------------------------------------
	# Static class constants
	# ----------------------------------------------------------------------------------------------------
	Object.defineProperty NavigationProducer.prototype, 'SUBSCRIPTION_KEYS',
		value: [
			SubscriptionKeys.HIGHLIGHTED_GROUPS_CHANGE
		]


	Object.defineProperty NavigationProducer.prototype, 'QUERY_KEYS',
		value: [
			QueryKeys.HIGHLIGHTED_GROUPS
		]


	Object.defineProperty NavigationProducer.prototype, 'NAME',
		value: 'NavigationProducer'


	# ----------------------------------------------------------------------------------------------------
	NavigationProducer

