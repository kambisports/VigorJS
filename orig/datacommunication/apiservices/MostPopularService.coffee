define (require) ->

	$ = require 'jquery'
	ApiService = require 'datacommunication/apiservices/ApiService'
	EventBus = require 'common/EventBus'
	EventKeys = require 'datacommunication/EventKeys'

	class MostPopularService extends ApiService

		prefetchDataKey: 'prefetched3way'

		constructor: ->
			super 15000

		run: (options) ->
			do @startPolling

		parse: (response) ->
			super response

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
			@propagateResponse @EVENTS_RECEIVED, eventObjs

		# Helper to set betoffers and outcomes in corresponding store
		_parseBetoffers: (betofferObjs) ->
			betoffers = []
			outcomes = []

			betoffers = _.map betofferObjs, (betoffer) ->
				betoffer.betofferType = betoffer.betOfferType
				delete betoffer.betOfferType
				_.omit betoffer, 'outcomes'

			outcomes = _.map _.flatten(_.pluck(betofferObjs, 'outcomes')), (outcome) ->
				outcome.betofferId = outcome.betOfferId
				delete outcome.betOfferId
				return outcome

			@propagateResponse @BETOFFERS_RECEIVED, betoffers
			@propagateResponse @OUTCOMES_RECEIVED, outcomes


		NAME: 'MostPopularService'

		EVENTS_RECEIVED: 'events-received'
		BETOFFERS_RECEIVED: 'betoffers-received'
		OUTCOMES_RECEIVED: 'outcomes-received'

	return new MostPopularService()



