define (require) ->
	BetofferTypes = require './betoffer/BetofferTypes'
	BetofferEvents = require './betoffer/BetofferEvents'
	OutcomeTypes = require './outcomes/OutcomeTypes'
	MostPopularEvents = require './mostpopular/MostPopularEvents'

	Constants =
		BetofferTypes: BetofferTypes
		BetofferEvents: BetofferEvents
		OutcomeTypes: OutcomeTypes
		MostPopularEvents: MostPopularEvents