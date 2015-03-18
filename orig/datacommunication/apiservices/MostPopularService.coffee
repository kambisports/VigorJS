define (require) ->

	$ = require 'jquery'
	KambiApiService = require 'datacommunication/apiservices/KambiApiService'
	EventBus = require 'common/EventBus'
	EventKeys = require 'datacommunication/EventKeys'

	BetofferParser = require 'datacommunication/apiservices/parsers/BetofferParser'
	OutcomeParser = require 'datacommunication/apiservices/parsers/OutcomeParser'
	EventParser = require 'datacommunication/apiservices/parsers/EventParser'

	class MostPopularService extends KambiApiService

		prefetchDataKey: 'prefetched3way'

		parse: (response) ->
			# Remove this when the betslip has been converted
			# This sends the response to the C_PARSE_MOST_POPULAR command which stores

			# the models in the facade
			$clonedResponse = $.extend(true, {}, response)
			EventBus.send EventKeys.FACADE_PARSE_MOSTPOPULAR, $clonedResponse

			# Set the data in our repositories so that components later on can request (query) that data
			@_parseEvents response.events
			@_parseBetoffers response.betoffers

		# Helper to update the EventsRepository
		_parseEvents: (eventObjs) ->
			events = _.map eventObjs, (event) ->
				EventParser.parse event

			@propagateResponse @EVENTS_RECEIVED, events

		# Helper to set betoffers and outcomes in corresponding store
		_parseBetoffers: (betofferObjs) ->
			betoffers = []
			outcomes = []

			betoffers = _.map betofferObjs, (betoffer) ->
				BetofferParser.parse betoffer

			outcomes = _.map _.flatten(_.pluck(betofferObjs, 'outcomes')), (outcome) ->
				OutcomeParser.parse outcome

			@propagateResponse @BETOFFERS_RECEIVED, betoffers
			@propagateResponse @OUTCOMES_RECEIVED, outcomes


		EVENTS_RECEIVED: 'events-received'
		BETOFFERS_RECEIVED: 'betoffers-received'
		OUTCOMES_RECEIVED: 'outcomes-received'

		urlPath: ->
			'/betoffer/mostpopular/3way.json'

	new MostPopularService()
