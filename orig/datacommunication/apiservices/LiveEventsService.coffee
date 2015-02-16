define (require) ->

	_ = require 'lib/underscore'
	ApiService = require 'datacommunication/apiservices/ApiService'

	class LiveEventsService extends ApiService

		constructor: () ->
			super 5000

		run: (options) ->
			do @startPolling

		parse: (response) ->
			super response

			liveEvents = response.liveEvents
			group = response.group

			@_parseEvents liveEvents
			@_parseGroups group

		_parseEvents: (liveEventObjs) ->

			matchClocks = []
			scores = []
			statistics = []

			# Parse matchclocks, scores and statistics
			_.map liveEventObjs, (eventObj) ->

				matchClock = { eventId: eventObj.event.id }
				_.extend matchClock, eventObj.liveData.matchClock
				matchClocks.push matchClock

				score = { eventId: eventObj.event.id }
				_.extend score, eventObj.liveData.score
				scores.push score

				stats = { eventId: eventObj.event.id }
				_.extend stats, eventObj.liveData.statistics
				statistics.push stats


			betoffers = _.chain liveEventObjs
				.pluck 'mainBetOffer'
				.compact()
				.value()

			outcomes = _.chain betoffers
				.pluck 'outcomes'
				.compact()
				.value()

			events = _.map liveEventObjs, (eventObj) ->
				eventObj.event.open = eventObj.liveData.open

				delete eventObj.mainBetOffer
				delete eventObj.liveData
				eventObj.event

			@propagateResponse @EVENTS_RECEIVED, events
			@propagateResponse @BETOFFERS_RECEIVED, betoffers
			@propagateResponse @OUTCOMES_RECEIVED, outcomes

			@propagateResponse @SCORES_RECEIVED, scores
			@propagateResponse @MATCH_CLOCKS_RECEIVED, matchClocks
			@propagateResponse @STATISTICS_RECEIVED, statistics


		_parseGroups: (groups) ->


		GROUPS_RECEIVED: 'groups-received'
		EVENTS_RECEIVED: 'events-received'
		BETOFFERS_RECEIVED: 'betoffers-received'
		OUTCOMES_RECEIVED: 'outcomes-received'
		SCORES_RECEIVED: 'scores-received'
		STATISTICS_RECEIVED: 'statistics-received'
		MATCH_CLOCKS_RECEIVED: 'match-clocks-received'

		NAME: 'LiveEventsService'

	return new LiveEventsService()


