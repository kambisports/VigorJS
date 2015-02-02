define (require) ->

	Repository = require 'datacommunication/repositories/Repository'
	EventModel = require 'datacommunication/repositories/events/EventModel'

	class EventsRepository extends Repository

		model: EventModel

		queryEvent: (options) ->
			return @findWhere {'id': options.eventId}

		makeTestInstance: ->
			new EventsRepository()

	return new EventsRepository()