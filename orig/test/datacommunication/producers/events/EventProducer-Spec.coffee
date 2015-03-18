define (require) ->

	SubscriptionKeys = require 'datacommunication/SubscriptionKeys'
	ComponentIdentifier = require 'datacommunication/ComponentIdentifier'
	EventProducer = require 'datacommunication/producers/events/EventProducer'

	EventRepository = require 'datacommunication/repositories/events/EventsRepository'

	describe 'An EventProducer', ->

		eventProducer = undefined
		mockComponent = undefined
		mockEvent = undefined

		beforeEach ->
			# Mock singleton instances
			eventProducer = new EventProducer()

			mockEvent =
				id: 12345
				homeName: "Luch Vladivostok"
				awayName: "Baltika Kaliningrad"
				boUri: "/offering/api/v2/ub/betoffer/live/event/1002502429.json"
				englishName: "Luch Vladivostok - Baltika Kaliningrad"
				group: "FNL"
				groupId: 1000157716
				hideStartNo: true
				liveBetOffers: true
				name: "Luch Vladivostok - Baltika Kaliningrad"
				openForLiveBetting: true
				# path: [{id: 1000093190, name: "Football", englishName: "Football"},…]
				sport: "FOOTBALL"
				sportId: 1000093190
				start: "2015-02-16T14:15Z"
				state: "STARTED"
				streamed: true
				streams: [{channelId: 1}, {channelId: 3}]
				type: "ET_MATCH"

			EventRepository.set
				id: 12345
				homeName: "Luch Vladivostok"
				awayName: "Baltika Kaliningrad"
				boUri: "/offering/api/v2/ub/betoffer/live/event/1002502429.json"
				englishName: "Luch Vladivostok - Baltika Kaliningrad"
				group: "FNL"
				groupId: 1000157716
				hideStartNo: true
				liveBetOffers: true
				name: "Luch Vladivostok - Baltika Kaliningrad"
				openForLiveBetting: true
				# path: [{id: 1000093190, name: "Football", englishName: "Football"},…]
				sport: "FOOTBALL"
				sportId: 1000093190
				start: "2015-02-16T14:15Z"
				state: "STARTED"
				streamed: true
				streams: [{channelId: 1}, {channelId: 3}]
				type: "ET_MATCH"
			, {silent: true}

			componentCb = () ->
			mockComponent = new ComponentIdentifier 'MockComponent_1', componentCb, { eventId: 12345 }

			eventProducer.addComponent SubscriptionKeys.EVENT, mockComponent

		describe 'should produce data', ->

			it 'on defined format', ->
				# How do we vertify that the format on which a producer produces on is correct?
				###
				spyOn(mockComponent, 'callback').andCallFake (jsonData) ->
					console.log 'Json fake callback', jsonData

				spyOn(eventProducer, 'produce').andCallThrough()

				runs ->
					mockEvent = EventRepository.get 12345
					mockEvent.set 'homeName', 'HomeName-Changed'

				waitsFor ->
					return (eventProducer.produce.callCount > 0)
				, 'EventProducer.produce was never run', 100

				runs ->
					expect(mockComponent.callback).toHaveBeenCalled()
				###



			it 'when event that producer subscribes to changes', ->

				EventRepository.set mockEvent, { silent: true }

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
