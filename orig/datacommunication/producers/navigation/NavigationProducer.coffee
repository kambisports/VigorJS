define (require) ->

	Producer = require 'datacommunication/producers/Producer'

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
			GroupsRepository.off GroupsRepository.REPOSITORY_DIFF, @_onRepositoryChange


		# ------------------------------------------------------------------------------------------------
		subscribe: (subscriptionKey, options) ->
			GroupsRepository.interestedInUpdates @NAME

			#Check if data is fresh here?
			@_produceData subscriptionKey

		_produceData: (key) ->
			switch key

				when SubscriptionKeys.SPORTS_GROUPS
					sortAlphabetically = false
					@produce key, @_buildSportsGroupsData sortAlphabetically

				when SubscriptionKeys.SPORTS_ATOZ_GROUPS
					sortAlphabetically = true
					@produce key, @_buildSportsGroupsData sortAlphabetically

				when SubscriptionKeys.HIGHLIGHTED_GROUPS
					@produce key, @_buildHighlightedGroupsData()

				else
					throw new Error("Unknown query subscriptionKey: #{key}")

		# ------------------------------------------------------------------------------------------------
		_buildSportsGroupsData: (sortAlphabetically) ->
			groups = GroupsRepository.querySportsGroups(sortAlphabetically)

			return @_getModifiedGroups groups

		# ------------------------------------------------------------------------------------------------
		_buildHighlightedGroupsData: ->
			highlightedGroups = GroupsRepository.queryHighlightedGroups()
			groupsFromLocalStorage = @_getGroupsFromLocalStorage()

			for groupId in groupsFromLocalStorage
				group = GroupsRepository.getGroupById(groupId)
				if group
					highlightedGroups.push group

			return @_getModifiedGroups highlightedGroups

		_getGroupsFromLocalStorage: () ->
			punterSettings = LocalStorageRepository.queryPunterSettings()
			groupsFromLocalStorage = punterSettings?.navigation?.leagues or []
			groupsFromLocalStorage

		# Takes a list of group models, appends extra data and returns a list
		# with the modified group JSON objects.
		_getModifiedGroups: (groups) ->
			modifiedGroups = []

			for group in groups
				groupJSON = group.toJSON()
				groupJSON.eventPath = @_getGroupPath groupJSON
				modifiedGroups.push groupJSON

			modifiedGroups

		_getGroupPath: (groupJSON) ->
			reverse = true
			separator = ' / '
			skipFirst = true
			GroupsRepository.getLocalizedGroupPathById groupJSON.id, separator, reverse, skipFirst

		# ------------------------------------------------------------------------------------------------
		_onRepositoryChange: (e) =>
			@_produceData SubscriptionKeys.SPORTS_GROUPS
			@_produceData SubscriptionKeys.SPORTS_ATOZ_GROUPS
			@_produceData SubscriptionKeys.HIGHLIGHTED_GROUPS

		# ------------------------------------------------------------------------------------------------
		SUBSCRIPTION_KEYS: [
			SubscriptionKeys.HIGHLIGHTED_GROUPS,
			SubscriptionKeys.SPORTS_ATOZ_GROUPS,
			SubscriptionKeys.SPORTS_GROUPS
		]

		NAME: 'NavigationProducer'
