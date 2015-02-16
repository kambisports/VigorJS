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

		constructor: ->
			super
			EventsRepository.on EventsRepository.REPOSITORY_DIFF, @_onDiffInRepository, @

		dispose: ->
			EventsRepository.off EventsRepository.REPOSITORY_DIFF, @_onDiffInRepository, @
			super

		subscribe: ->
			do EventsRepository.fetchLiveEvents
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

