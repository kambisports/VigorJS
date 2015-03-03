define (require) ->

	Backbone = require 'lib/backbone'
	ViewModel = require 'common/ViewModel'
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
			@subscribe SubscriptionKeys.EVENT, @onEventChange, {eventId: @eventId}

		onEventChange: (event) =>
			@event.set event

	return EventItemModel