define (require) ->

	{
		parse: (outcome) ->

			{
				id: outcome.id
				betofferId: outcome.betOfferId

				changedDate: outcome.changedDate
				label: outcome.label

				odds: outcome.odds
				oddsAmerican: outcome.oddsAmerican
				oddsFractional: outcome.oddsFractional

				popular: if outcome.popular? then outcome.popular else false #?
				type: outcome.type
			}
	}