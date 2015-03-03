define (require) ->

	SubscriptionKeys = require 'datacommunication/SubscriptionKeys'
	ComponentIdentifier = require 'datacommunication/ComponentIdentifier'
	MostPopularProducer = require 'datacommunication/producers/mostpopular/MostPopularProducer'

	EventsRepository = require 'datacommunication/repositories/events/EventsRepository'
	BetoffersRepository = require 'datacommunication/repositories/betoffers/BetoffersRepository'
	OutcomesRepository = require 'datacommunication/repositories/outcomes/OutcomesRepository'

	MostPopularService = require 'datacommunication/apiservices/MostPopularService'

	describe 'An MostPopularProducer', ->

		mostPopularProducer = undefined
		mockComponent = undefined

		beforeEach ->
			MostPopularService.parse jasmine.kambi.data.getMostPopular3()
			mostPopularProducer = new MostPopularProducer()

			componentCb = () ->
			mockComponent = new ComponentIdentifier 'MockComponent_1', componentCb, {}

			mostPopularProducer.addComponent SubscriptionKeys.MOST_POPULAR_EVENTS, mockComponent

		describe 'should produce data', ->

			it 'when event that producer subscribes to changes', ->
				spyOn(mockComponent, 'callback').andCallThrough()
				spyOn(mostPopularProducer, 'produce').andCallThrough()

				runs ->
					mockEvent = EventsRepository.get 1002426458
					mockEvent.set 'homeName', 'HomeName-Changed'

				waitsFor ->
					return (mostPopularProducer.produce.callCount > 0)
				, 'EventProducer.produce was never run', 110

				runs ->
					expect(mockComponent.callback).toHaveBeenCalled()

			it 'the data shuld be in the correct format', ->
				data = mostPopularProducer._buildData()
				expect(data.events.length).toBe(5)
				expect(data.selectedOutcomes.length).toBe(5)
				expect(data.defaultStakes.length).toBe(6)
				expect(data.events[0].betofferId).toBe(2009868614)
				expect(data.events[0].eventId).toBe(1002426458)
				expect(data.selectedOutcomes[0].odds).toBe(2850)
				expect(data.selectedOutcomes[0].outcomeId).toBe(2036697573)

			it 'should only include betoffers of the type three way', ->
				data = mostPopularProducer._buildData()
				for event in data.events
					betoffer = BetoffersRepository.get event.betofferId
					betofferType = betoffer.get('betofferType').id
					expect(betofferType).toBe(2)

			it 'correct number of popular outcomes', ->
				data = mostPopularProducer._buildData()
				for outcome in data.selectedOutcomes
					outcomeModel = OutcomesRepository.get outcome.outcomeId
					expect(outcomeModel.get('popular')).toBe(true)
				expect(data.selectedOutcomes.length).toBe(5)

