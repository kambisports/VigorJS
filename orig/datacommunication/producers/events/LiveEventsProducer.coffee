define (require) ->

	Producer = require 'datacommunication/producers/Producer'
	SubscriptionKeys = require 'datacommunication/SubscriptionKeys'

	# Collections needed to build/produce data
	EventsRepository = require 'datacommunication/repositories/events/EventsRepository'
	# MatchClocksRepository = require 'datacommunication/repositories/matchclocks/MatchClocksRepository'
	# ScoresRepository = require 'datacommunication/repositories/scores/ScoresRepository'
	# StatisticsRepository = require 'datacommunication/repositories/statistics/StatisticsRepository'
	# decorateModels = require 'datacommunication/producers/mixins/decorateModels'

	class LiveEventsProducer extends Producer

		# the fetch subscription to the repository
		repoFetchSubscription: undefined

		constructor: ->
			super
			EventsRepository.on EventsRepository.REPOSITORY_DIFF, @_onDiffInRepository, @

		dispose: ->
			EventsRepository.off EventsRepository.REPOSITORY_DIFF, @_onDiffInRepository, @
			EventsRepository.removeSubscription EventsRepository.LIVE, @repoFetchSubscription
			super

		subscribe: ->

			@repoFetchSubscription =
				pollingInterval: 5000

			EventsRepository.addSubscription EventsRepository.LIVE, @repoFetchSubscription

			do @_produceData

		# ------------------------------------------------------------------------------------------------
		_produceData: ->
			@produce SubscriptionKeys.LIVE_EVENTS, @_buildData()

		_buildData: ->
			liveEvents = EventsRepository.getLiveEvents()
			liveEvents = @modelsToJSON liveEvents
			return liveEvents

		# ------------------------------------------------------------------------------------------------
		_onDiffInRepository: ->
			do @_produceData

		SUBSCRIPTION_KEYS: [SubscriptionKeys.LIVE_EVENTS]
		NAME: 'LiveEventsProducer'

