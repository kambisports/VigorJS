define (require) ->

	_ = require 'lib/underscore'
	KambiApiService = require 'datacommunication/apiservices/KambiApiService'

	responseFlattener = require 'datacommunication/apiservices/utils/responseFlattener'

	BetofferParser = require 'datacommunication/apiservices/parsers/BetofferParser'
	OutcomeParser = require 'datacommunication/apiservices/parsers/OutcomeParser'
	EventParser = require 'datacommunication/apiservices/parsers/EventParser'

	class LiveEventsService extends KambiApiService

		parse: (response) ->
			liveEvents = response.liveEvents
			group = response.group

			@_parseEvents liveEvents
			@_parseGroups response


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
				.flatten()
				.value()

			betoffers = _.map betoffers, (betoffer) ->
				BetofferParser.parse betoffer

			outcomes = _.chain betoffers
				.pluck 'outcomes'
				.compact()
				.flatten()
				.value()

			outcomes = _.map outcomes, (outcome) ->
				OutcomeParser.parse outcome

			# add open status from live data to event
			events = _.map liveEventObjs, (eventObj) ->
				eventObj.event.open = eventObj.liveData.open
				delete eventObj.mainBetOffer
				delete eventObj.liveData
				EventParser.parse eventObj.event

			@propagateResponse @EVENTS_RECEIVED, events
			@propagateResponse @BETOFFERS_RECEIVED, betoffers
			@propagateResponse @OUTCOMES_RECEIVED, outcomes

			@propagateResponse @SCORES_RECEIVED, scores
			@propagateResponse @MATCH_CLOCKS_RECEIVED, matchClocks
			@propagateResponse @STATISTICS_RECEIVED, statistics


		_parseGroups: (response) ->
			flatGroupModels = @flattenResponse response
			@propagateResponse @GROUPS_RECEIVED, flatGroupModels


		flattenResponse: (response) ->
			groupModels = @getGroupsFromResponse response

			flatteningSpecs =
				flattenMethod: responseFlattener.METHOD_BREADTH_FIRST
				uniqueIdentifier: 'id'
				indexName: 'groups'
				startLevel: 1

			flattenedResponse = responseFlattener.flatten groupModels, flatteningSpecs

			return flattenedResponse

		getGroupsFromResponse: (response) ->
			groupsExistsInResponse = response?.group and response?.group?.groups

			if not groupsExistsInResponse
				throw 'The response object does not contain the necessary groups tree structure.'
			else
				groups = response.group.groups

			return groups


		GROUPS_RECEIVED: 'groups-received'
		EVENTS_RECEIVED: 'events-received'
		BETOFFERS_RECEIVED: 'betoffers-received'
		OUTCOMES_RECEIVED: 'outcomes-received'
		SCORES_RECEIVED: 'scores-received'
		STATISTICS_RECEIVED: 'statistics-received'
		MATCH_CLOCKS_RECEIVED: 'match-clocks-received'

		urlPath: ->
			'/event/live/open.json'

	new LiveEventsService()
