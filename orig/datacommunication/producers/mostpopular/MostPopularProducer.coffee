define (require) ->

	_ = require 'lib/underscore'
	ApplicationSettingsModel = require 'datacommunication/models/ApplicationSettingsModel'
	StringUtil = require 'utils/StringUtil'
	Producer = require 'datacommunication/producers/Producer'

	SubscriptionKeys = require 'datacommunication/SubscriptionKeys'

	# Collections needed to build/produce data
	EventsRepository = require 'datacommunication/repositories/events/EventsRepository'
	BetoffersRepository = require 'datacommunication/repositories/betoffers/BetoffersRepository'
	OutcomesRepository = require 'datacommunication/repositories/outcomes/OutcomesRepository'

	DefaultStakes = require './DefaultStakes'

	class MostPopularProducer extends Producer

		constructor: ->
			super
			EventsRepository.on EventsRepository.REPOSITORY_DIFF, @_onDiffInRepository, @

		dispose: ->
			EventsRepository.off EventsRepository.REPOSITORY_DIFF, @_onDiffInRepository, @
			super

		subscribe: (subscriptionKey, options) ->
			EventsRepository.fetchMostPopularEvents options
			do @_produceData

		_produceData: ->
			@produce SubscriptionKeys.MOST_POPULAR_EVENTS, @_buildData()

		_buildData: ->
			formattedData = {}
			events = []
			selectedOutcomes = []
			mostPopularBetoffers = BetoffersRepository.getMostPopularBetoffers()

			for betoffer in mostPopularBetoffers
				outcomes = _.map OutcomesRepository.getOutcomesByBetofferId(betoffer.id), (outcome) ->
					outcome.toJSON()

				event =
					eventId: betoffer.get 'eventId'
					betofferId: betoffer.get 'id'

				selectedOutcome =
					outcomeId: (_.findWhere outcomes, { popular: true }).id
					odds: (_.findWhere outcomes, { popular: true }).odds

				events.push event
				selectedOutcomes.push selectedOutcome

			currency = ApplicationSettingsModel.get 'currency'
			currencyKey = "#{StringUtil.toUpperCase(currency)}_CURRENCY_DEFAULT_STAKES"

			formattedData.events = events
			formattedData.selectedOutcomes = selectedOutcomes
			formattedData.defaultStakes = DefaultStakes[currencyKey]

			return formattedData

		# Handlers
		_onDiffInRepository:  =>
			do @_produceData

		SUBSCRIPTION_KEYS: [SubscriptionKeys.MOST_POPULAR_EVENTS]

		NAME: 'MostPopularProducer'
