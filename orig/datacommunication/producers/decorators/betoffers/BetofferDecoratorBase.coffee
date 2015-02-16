define (require) ->

	OutcomesRepository = require 'datacommunication/repositories/outcomes/OutcomesRepository'

	class BetofferDecoratorBase

		addOutcomesToBetoffer: (betofferJSON) ->
			betofferId = betofferJSON.id
			outcomeObjs = []
			outcomeModels = OutcomesRepository.getOutcomesByBetofferId betofferId

			for outcomeModel in outcomeModels
				outcome = outcomeModel.toJSON()
				outcome.displayOdds = (outcome.odds / 1000).toFixed(2)
				if outcome.popular
					outcome.highlight = true
				outcomeObjs.push outcome

			betofferJSON.outcomes = outcomeObjs
			return betofferJSON


	return BetofferDecoratorBase
