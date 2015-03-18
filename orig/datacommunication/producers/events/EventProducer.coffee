define (require) ->

	Producer = require 'datacommunication/producers/Producer'
	SubscriptionKeys = require 'datacommunication/SubscriptionKeys'

	EventsRepository = require 'datacommunication/repositories/events/EventsRepository'
	eventDecoratorBase = require 'datacommunication/producers/decorators/events/eventDecoratorBase'

	class EventProducer extends Producer

		subscribeToRepositories: ->
			EventsRepository.on EventsRepository.REPOSITORY_DIFF, @_onDiffInRepository, @

		unsubscribeFromRepositories: ->
			EventsRepository.off EventsRepository.REPOSITORY_DIFF, @_onDiffInRepository, @

		subscribe: (subscriptionKey, options) ->
			model = EventsRepository.get options.eventId
			@_produceData [model]

		# ------------------------------------------------------------------------------------------------
		_produceData: (events = [])->
			unless events.length > 0 then return

			events = _.without events, undefined
			events = @modelsToJSON events

			for event in events
				event = @decorate event, [
					eventDecoratorBase.addUrl
				]
				@produce SubscriptionKeys.EVENT, event, (componentOptions) ->
					event.id is componentOptions.eventId

		# ------------------------------------------------------------------------------------------------
		_onDiffInRepository: (dataDiff) ->
			if dataDiff.consolidated.length > 0
				@_produceData dataDiff.consolidated

		SUBSCRIPTION_KEYS: [SubscriptionKeys.EVENT]
