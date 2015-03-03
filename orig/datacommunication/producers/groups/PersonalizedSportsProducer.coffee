define (require) ->

	Producer = require 'datacommunication/producers/Producer'
	SubscriptionKeys = require 'datacommunication/SubscriptionKeys'
	GroupsRepository = require 'datacommunication/repositories/groups/GroupsRepository'
	LocalStorageRepository = require 'datacommunication/repositories/localstorage/LocalStorageRepository'

	# mixins
	getSportsFromLocalStorage = require 'datacommunication/producers/mixins/groups/getSportsFromLocalStorage'
	decorateModels = require 'datacommunication/producers/mixins/decorateModels'

	groupDecorator = require 'datacommunication/producers/decorators/groups/groupDecoratorBase'


	class PersonalizedSportsProducer extends Producer

		# the fetch subscription to the repository
		repoFetchSubscription: undefined

		constructor: ->
			LocalStorageRepository.on 'change:key_punter_setting', @_onRepositoryChange
			GroupsRepository.on GroupsRepository.REPOSITORY_DIFF, @_onRepositoryChange
			@mixin @, decorateModels
			@mixin @, getSportsFromLocalStorage
			super

		# ------------------------------------------------------------------------------------------------
		dispose: ->
			LocalStorageRepository.off 'change:key_punter_setting', @_onRepositoryChange
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
			@produce SubscriptionKeys.PERSONALIZED_SPORTS, @_buildData()

		_buildData: ->
			topSports = GroupsRepository.getTopSports()
			sportsFromLocalStorage = @getSportsFromLocalStorage()
			topSports = topSports.concat sportsFromLocalStorage
			totalSportsCount = GroupsRepository.getGroupsByLevel(1).length

			decoratorList = [
				groupDecorator.addUrl
			]

			topSports = @decorateModels(topSports, decoratorList)

			topSportsData =
				topSports: topSports
				totalSportsCount: totalSportsCount

			return topSportsData

		# ------------------------------------------------------------------------------------------------
		_onRepositoryChange: =>
			do @_produceData

		# ------------------------------------------------------------------------------------------------
		SUBSCRIPTION_KEYS: [SubscriptionKeys.PERSONALIZED_SPORTS]
		NAME: 'PersonalizedSportsProducer'

	PersonalizedSportsProducer
