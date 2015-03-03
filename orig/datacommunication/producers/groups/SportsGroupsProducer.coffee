define (require) ->

	Producer = require 'datacommunication/producers/Producer'
	SubscriptionKeys = require 'datacommunication/SubscriptionKeys'
	GroupsRepository = require 'datacommunication/repositories/groups/GroupsRepository'

	# mixins
	decorateModels = require 'datacommunication/producers/mixins/decorateModels'

	groupDecorator = require 'datacommunication/producers/decorators/groups/groupDecoratorBase'

	class SportsGroupsProducer extends Producer

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
			@produce SubscriptionKeys.SPORTS_GROUPS, @_buildData()

		# ------------------------------------------------------------------------------------------------
		_buildData: ->
			# decorators
			sportsGroups = GroupsRepository.getSportsGroups()

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
		SUBSCRIPTION_KEYS: [SubscriptionKeys.SPORTS_GROUPS]
		NAME: 'SportsGroupsProducer'

	SportsGroupsProducer
