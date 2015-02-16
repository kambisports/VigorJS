define (require) ->

	ServiceRepository = require 'datacommunication/repositories/ServiceRepository'

	# services that receives data for this repo
	MostPopularService = require 'datacommunication/apiservices/MostPopularService'
	LiveEventsService = require 'datacommunication/apiservices/LiveEventsService'

	# the repo holds a collection of this model type
	EventModel = require 'datacommunication/repositories/events/EventModel'

	class EventsRepository extends ServiceRepository

		model: EventModel
		mostPopularEvents: undefined

		initialize: ->
			MostPopularService.on MostPopularService.EVENTS_RECEIVED, @_onMostPopularEventsReceived
			LiveEventsService.on LiveEventsService.EVENTS_RECEIVED, @_onLiveEventsReceived
			@mostPopularEvents = []
			super

		fetchEvent: (options) ->
			@callApiService LiveEventsService.NAME, options
			@callApiService MostPopularService.NAME, options
			return @getEvent(options.eventId)

		fetchMostPopularEvents: (options) ->
			@callApiService MostPopularService.NAME, options
			return @getMostPopularEvents()

		fetchLiveEvents: (options) ->
			@callApiService LiveEventsService.NAME, options
			return @getLiveEvents()

		getEvent: (id) ->
			return @findWhere { 'id': id }

		getLiveEvents: ->
			# what would be the proper check for this? (TODO: make sure this is parsed correctly)
			return @where { 'state': 'STARTED' }

		getMostPopularEvents: ->
			return @mostPopularEvents

		_onEventsReceived: (models) =>
			@set models, { remove: false }

		_onLiveEventsReceived: (models) =>
			@set models, { remove: false }

		_onMostPopularEventsReceived: (models) =>
			mostPopularEventIds = _.map models, (model) ->
				return model.id
			@set models, { remove: false }
			@mostPopularEvents = @getByIds mostPopularEventIds

		makeTestInstance: ->
			new EventsRepository()

	return new EventsRepository()