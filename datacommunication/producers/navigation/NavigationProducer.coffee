define (require) ->

	Producer = require 'datacommunication/producers/Producer'
	Q = require 'lib/q'
	QueryKeys = require 'datacommunication/QueryKeys'
	SubscriptionKeys = require 'datacommunication/SubscriptionKeys'
	GroupsRepository = require 'datacommunication/repositories/groups/GroupsRepository'
	LocalStorageRepository = require 'datacommunication/repositories/localstorage/LocalStorageRepository'

	class NavigationProducer extends Producer

		constructor: ->
			LocalStorageRepository.on 'change:key_punter_setting', @_onRepositoryChange
			GroupsRepository.on GroupsRepository.REPOSITORY_DIFF, @_onRepositoryChange

			super
		# ------------------------------------------------------------------------------------------------
		dispose: ->
			GroupsRepository.notInterestedInUpdates @NAME
			LocalStorageRepository.off 'change:key_punter_setting', @_onRepositoryChange
			GroupsRepository.on GroupsRepository.REPOSITORY_DIFF, @_onRepositoryChange


		# ------------------------------------------------------------------------------------------------
		subscribe: (subscriptionKey, options) ->
			GroupsRepository.interestedInUpdates @NAME

			#Check if data is fresh here?
			@_produceData subscriptionKey

		_produceData: (key) ->
			switch key
				when SubscriptionKeys.SPORTS_GROUPS_CHANGE
					@produce key, @_buildSportsGroupsData()
				when SubscriptionKeys.HIGHLIGHTED_GROUPS_CHANGE
					@produce key, @_buildHighlightedGroupsData()
				else
					throw new Error("Unknown query subscriptionKey: #{key}")

		# ------------------------------------------------------------------------------------------------
		_buildSportsGroupsData: ->
			groups = GroupsRepository.querySportsGroups()
			modifiedData = []
			reverse = true
			separator = ' / '
			skipFirst = true

			for model in groups
				model = model.toJSON()
				eventPath = GroupsRepository.getLocalizedGroupPathById model.id, separator, reverse, skipFirst
				model.eventPath = eventPath
				modifiedData.push model

			return modifiedData

		# ------------------------------------------------------------------------------------------------
		_buildHighlightedGroupsData: ->
			punterSettings = LocalStorageRepository.queryPunterSettings()
			highlightedGroups = GroupsRepository.queryHighlightedGroups()
			groupsFromLocalStorage = punterSettings?.navigation?.leagues or []
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
		_onGroupsChange: =>
			@_produceData SubscriptionKeys.SPORTS_GROUPS_CHANGE

		_onRepositoryChange: =>
			@_produceData SubscriptionKeys.HIGHLIGHTED_GROUPS_CHANGE

		# ------------------------------------------------------------------------------------------------
		SUBSCRIPTION_KEYS: [
			SubscriptionKeys.HIGHLIGHTED_GROUPS_CHANGE,
			SubscriptionKeys.SPORTS_GROUPS_CHANGE
		]

		NAME: 'NavigationProducer'
