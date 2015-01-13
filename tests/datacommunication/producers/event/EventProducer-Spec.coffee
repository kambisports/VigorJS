define (require) ->

	SubscriptionKeys = require 'datacommunication/SubscriptionKeys'
	ComponentIdentifier = require 'datacommunication/ComponentIdentifier'
	EventProducer = require 'datacommunication/producers/event/EventProducer'

	EventRepository = require 'datacommunication/repositories/events/EventsRepository'

	describe 'An EventProducer', ->

		eventProducer = undefined
		mockComponent = undefined

		beforeEach ->
			# Mock singleton instances
			eventProducer = new EventProducer()

			EventRepository.set {id: 12345, homeName: 'HomeName', awayName: 'AwayName'}, {silent: true}

			componentCb = () ->
			mockComponent = new ComponentIdentifier 'MockComponent_1', componentCb, { eventId: 12345 }

			eventProducer.addComponent SubscriptionKeys.EVENT_CHANGE, mockComponent

		describe 'should produce data', ->

			it 'when event that producer subscribes to changes', ->

				spyOn(mockComponent, 'callback').andCallThrough()
				spyOn(eventProducer, 'produce').andCallThrough()

				runs ->
					mockEvent = EventRepository.get 12345
					mockEvent.set 'homeName', 'HomeName-Changed'

				waitsFor ->
					return (eventProducer.produce.callCount > 0)
				, 'EventProducer.produce was never run', 100

				runs ->
					expect(mockComponent.callback).toHaveBeenCalled()
