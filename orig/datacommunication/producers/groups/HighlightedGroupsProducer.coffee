define (require) ->

	Producer = require 'datacommunication/producers/Producer'
	SubscriptionKeys = require 'datacommunication/SubscriptionKeys'
	GroupsRepository = require 'datacommunication/repositories/groups/GroupsRepository'
	LocalStorageRepository = require 'datacommunication/repositories/localstorage/LocalStorageRepository'

	# mixins
	getLeaguesFromLocalStorage = require 'datacommunication/producers/mixins/groups/getLeaguesFromLocalStorage'
	decorateModels = require 'datacommunication/producers/mixins/decorateModels'
	groupDecorator = require 'datacommunication/producers/decorators/groups/groupDecoratorBase'


	class HighlightedGroupsProducer extends Producer

		# the fetch subscription to the repository
		repoFetchSubscription: undefined

		constructor: ->
			LocalStorageRepository.on 'change:key_punter_setting', @_onRepositoryChange
			GroupsRepository.on GroupsRepository.REPOSITORY_DIFF, @_onRepositoryChange
			@mixin @, decorateModels
			@mixin @, getLeaguesFromLocalStorage
			super

		# ------------------------------------------------------------------------------------------------
		dispose: ->
			LocalStorageRepository.off 'change:key_punter_setting', @_onRepositoryChange
			GroupsRepository.off GroupsRepository.REPOSITORY_DIFF, @_onRepositoryChange
			GroupsRepository.removeSubscription GroupsRepository.HIGHLIGHTED, @repoFetchSubscription
			super

		subscribe: ->
			@repoFetchSubscription =
				pollingInterval: 5000

			GroupsRepository.addSubscription GroupsRepository.HIGHLIGHTED, @repoFetchSubscription

			do @_produceData

		# ------------------------------------------------------------------------------------------------
		_produceData: ->
			@produce SubscriptionKeys.HIGHLIGHTED_GROUPS, @_buildData()

		# ------------------------------------------------------------------------------------------------
		_buildData: ->
			highlightedGroups = GroupsRepository.getHighlightedGroups()
			groupsFromLocalStorage = @getGroupsFromLocalStorage()
			highlightedGroups = highlightedGroups.concat groupsFromLocalStorage

			decoratorList = [
				groupDecorator.addGroupPath,
				groupDecorator.addLocalizedGroupPath,
				groupDecorator.addStrippedLocalizedGroupPath,
				groupDecorator.addUrl
			]

			highlightedGroups = @decorateModels(highlightedGroups, decoratorList)
			return highlightedGroups

		# ------------------------------------------------------------------------------------------------
		_onRepositoryChange: =>
			do @_produceData

		# ------------------------------------------------------------------------------------------------
		SUBSCRIPTION_KEYS: [SubscriptionKeys.HIGHLIGHTED_GROUPS]
		NAME: 'HighlightedGroupsProducer'