define (require) ->

	Producer = require 'datacommunication/producers/Producer'
	SubscriptionKeys = require 'datacommunication/SubscriptionKeys'
	GroupsRepository = require 'datacommunication/repositories/groups/GroupsRepository'

	# mixins
	decorateModels = require 'datacommunication/producers/mixins/decorateModels'

	groupDecorator = require 'datacommunication/producers/decorators/groups/groupDecoratorBase'

	class SportsGroupsProducer extends Producer

		constructor: ->
			GroupsRepository.on GroupsRepository.REPOSITORY_DIFF, @_onRepositoryChange
			@mixin @, decorateModels
			super

		# ------------------------------------------------------------------------------------------------
		dispose: ->
			GroupsRepository.off GroupsRepository.REPOSITORY_DIFF, @_onRepositoryChange
			super

		subscribe: ->
			do GroupsRepository.fetchSportsGroups
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
