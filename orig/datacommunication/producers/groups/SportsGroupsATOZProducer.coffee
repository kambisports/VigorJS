define (require) ->

	Producer = require 'datacommunication/producers/Producer'
	SubscriptionKeys = require 'datacommunication/SubscriptionKeys'
	GroupsRepository = require 'datacommunication/repositories/groups/GroupsRepository'

	# mixins
	decorateModels = require 'datacommunication/producers/mixins/decorateModels'

	decorateModels = require 'datacommunication/producers/mixins/decorateModels'
	groupDecorator = require 'datacommunication/producers/decorators/groups/groupDecoratorBase'

	class SportsGroupsATOZProducer extends Producer

		# the fetch subscription to the repository
		repoFetchSubscription: undefined

		constructor: ->
			GroupsRepository.on GroupsRepository.REPOSITORY_DIFF, @_onRepositoryChange
			@mixin @, decorateModels
			super

		# ------------------------------------------------------------------------------------------------
		dispose: ->
			GroupsRepository.off GroupsRepository.REPOSITORY_DIFF, @_onRepositoryChange
			GroupsRepository.removeSubscription GroupsRepository.ALL, @repoFetchSubscription
			super

		subscribe: ->
			@repoFetchSubscription =
				pollingInterval: 1000 * 60 * 30

			GroupsRepository.addSubscription GroupsRepository.ALL, @repoFetchSubscription
			do @_produceData

		# ------------------------------------------------------------------------------------------------
		_produceData: ->
			@produce SubscriptionKeys.SPORTS_ATOZ_GROUPS, @_buildData()

		# ------------------------------------------------------------------------------------------------
		_buildData: ->
			sortAlphabetically = true
			sportsGroups = GroupsRepository.getSportsGroups(sortAlphabetically)

			decoratorList = [
				groupDecorator.addGroupPath,
				groupDecorator.addLocalizedGroupPath,
				groupDecorator.addStrippedLocalizedGroupPath,
				groupDecorator.addUrl
			]

			sportsGroups = @decorateModels(sportsGroups, decoratorList)
			return sportsGroups

		# ------------------------------------------------------------------------------------------------
		_onRepositoryChange: =>
			do @_produceData

		# ------------------------------------------------------------------------------------------------
		SUBSCRIPTION_KEYS: [SubscriptionKeys.SPORTS_ATOZ_GROUPS]
		NAME: 'SportsGroupsATOZProducer'

	SportsGroupsATOZProducer
