define (require) ->

	SubscriptionKeys = require 'datacommunication/SubscriptionKeys'
	ComponentIdentifier = require 'datacommunication/ComponentIdentifier'
	BetofferProducer = require 'datacommunication/producers/betoffer/BetofferProducer'

	BetofferRepository = require 'datacommunication/repositories/betoffers/BetoffersRepository'
	OutcomeRepository = require 'datacommunication/repositories/outcomes/OutcomesRepository'


	describe 'A BetofferProducer', ->

		betofferProducer = undefined
		mockComponent = undefined

		beforeEach ->
			# Mock singleton instances
			betofferProducer = new BetofferProducer()

			BetofferRepository.set [
				{id: 1, eventId: 11},
				{id: 2, eventId: 22}
			], {silent: true}

			OutcomeRepository.set [
				{id: 111, betofferId: 1, label: 'Outcome_1', odds: 1110},
				{id: 222, betofferId: 1, label: 'Outcome_2', odds: 2220},
				{id: 333, betofferId: 1, label: 'Outcome_3', odds: 3330},
				{id: 444, betofferId: 2, label: 'Outcome_4', odds: 4440}

			], {silent: true}

			mockComponentCb = () ->

			mockComponent = new ComponentIdentifier 'MockComponent_1', mockComponentCb, { betofferId: 1 }
			betofferProducer.addComponent SubscriptionKeys.BETOFFER, mockComponent

		describe 'should produce data', ->

			it 'when outcome included in bet offer that producer subscribes to changes', ->

				spyOn(mockComponent, 'callback').andCallThrough()
				spyOn(betofferProducer, 'produce').andCallThrough()

				runs ->
					outcomeToChange = OutcomeRepository.get 111
					outcomeToChange.set 'odds', 1115

				waitsFor ->
					return (betofferProducer.produce.callCount > 0)
				, 'BetofferProducer.produce was never run', 500

				runs ->
					expect(mockComponent.callback).toHaveBeenCalled()


		describe 'should not produce data', ->

			it 'when outcome not included in bet offer that producer subscribes to changes', ->

				spyOn(mockComponent, 'callback').andCallThrough()
				spyOn(betofferProducer, 'produce').andCallThrough()

				runs ->
					outcomeToChange = OutcomeRepository.get 444
					outcomeToChange.set 'odds', 4445

				waitsFor ->
					return (betofferProducer.produce.callCount > 0)
				, 'BetofferProducer.produce was never run', 500

				runs ->
					expect(mockComponent.callback).not.toHaveBeenCalled()