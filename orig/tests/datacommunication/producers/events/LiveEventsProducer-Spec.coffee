define (require) ->

	SubscriptionKeys = require 'datacommunication/SubscriptionKeys'
	ComponentIdentifier = require 'datacommunication/ComponentIdentifier'
	LiveEventsProducer = require 'datacommunication/producers/events/LiveEventsProducer'

	EventRepository = require 'datacommunication/repositories/events/EventsRepository'

	describe 'A LiveEventsProducer', ->

		liveEventsProducer = undefined
		mockComponent = undefined

		beforeEach ->
			# Mock singleton instances
			liveEventsProducer = new LiveEventsProducer()

			componentCb = () ->
			mockComponent = new ComponentIdentifier 'MockComponent_1', componentCb, {}

			liveEventsProducer.addComponent SubscriptionKeys.LIVE_EVENTS, mockComponent

		describe 'produce data when status of one or more events changes', ->

			it 'from NOT_STARTED to STARTED', ->

				EventRepository.set [
					{id: 1, status: 'NOT_STARTED'}
					{id: 2, status: 'NOT_STARTED'}
				], {silent: true}

				spyOn(mockComponent, 'callback').andCallThrough()
				spyOn(liveEventsProducer, 'produce').andCallThrough()

				runs ->
					mockEvent = EventRepository.get 1
					mockEvent.set 'status', 'STARTED'

				waitsFor ->
					return (liveEventsProducer.produce.callCount > 0)
				, 'LiveEventsProducer.produce was never run', 100

				runs ->
					expect(mockComponent.callback).toHaveBeenCalled()

			it 'from FINISHED to STARTED', ->

				EventRepository.set [
					{id: 1, status: 'FINISHED'}
					{id: 2, status: 'FINISHED'}
				], {silent: true}

				spyOn(mockComponent, 'callback').andCallThrough()
				spyOn(liveEventsProducer, 'produce').andCallThrough()

				runs ->
					mockEvent = EventRepository.get 2
					mockEvent.set 'status', 'STARTED'

				waitsFor ->
					return (liveEventsProducer.produce.callCount > 0)
				, 'LiveEventsProducer.produce was never run', 100

				runs ->
					expect(mockComponent.callback).toHaveBeenCalled()