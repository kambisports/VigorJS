define (require) ->

	Q = require 'lib/q'
	Repository = require 'datacommunication/repositories/Repository'
	EventModel = require 'datacommunication/repositories/events/EventModel'

	class EventsRepository extends Repository

		model: EventModel

		queryEvent: (options) ->
			deferred = Q.defer()
			deferred.resolve @findWhere {'id': options.eventId}
			return deferred.promise

		makeTestInstance: ->
			new EventsRepository()

	return new EventsRepository()