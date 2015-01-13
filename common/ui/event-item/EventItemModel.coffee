define (require) ->

	Backbone = require 'lib/backbone'
	ViewModel = require 'common/ViewModel'
	QueryKeys = require 'datacommunication/QueryKeys'
	SubscriptionKeys = require 'datacommunication/SubscriptionKeys'

	class EventItemModel extends ViewModel

		id: 'EventItemModel'
		eventId: undefined
		event: undefined

		constructor: (@eventId) ->
			super
			@event = new Backbone.Model()
			do @addSubscriptions

		addSubscriptions: ->
			promise = @queryAndSubscribe QueryKeys.EVENT,
				{ eventId: @eventId},
				SubscriptionKeys.EVENT_CHANGE,
				@onEventChange,
				{ eventId: @eventId }

			promise.then (event) =>
				@event.set event

			return promise

		onEventChange: (event) =>
			@event.set event

	return EventItemModel