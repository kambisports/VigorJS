define (require) ->

	Producer = require 'datacommunication/producers/Producer'
	SubscriptionKeys = require 'datacommunication/SubscriptionKeys'

	EventsRepository = require 'datacommunication/repositories/events/EventsRepository'
	eventDecoratorBase = require 'datacommunication/producers/decorators/events/eventDecoratorBase'

	class EventProducer extends Producer

		constructor: ->
			super
			EventsRepository.on EventsRepository.REPOSITORY_DIFF, @_onDiffInRepository, @

		dispose: ->
			EventsRepository.off EventsRepository.REPOSITORY_DIFF, @_onDiffInRepository, @
			super

		subscribe: (subscriptionKey, options) ->
			model = EventsRepository.get options.eventId
			@_produceData [model]

		# ------------------------------------------------------------------------------------------------
		_produceData: (events = [])->
			unless events.length > 0 then return

			events = _.without events, undefined
			events = @modelsToJSON events

			for event in events
				event = @decorate event, [eventDecoratorBase.addUrl]
				@produce SubscriptionKeys.EVENT, event, (componentOptions) ->
					event.id is componentOptions.eventId

		# ------------------------------------------------------------------------------------------------
		_onDiffInRepository: (dataDiff) ->
			if dataDiff.changed.length > 0
				@_produceData dataDiff.changed

		SUBSCRIPTION_KEYS: [SubscriptionKeys.EVENT]
		NAME: 'EventProducer'