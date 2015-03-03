define (require) ->

	{
		parse: (coupon, outcome, bet, eligibleForCashIn) ->
			id: "#{coupon.id}::#{outcome.id}"
			couponId: coupon.id
			outcomeId: outcome.id
			betofferId: outcome.betOfferId
			eventId: outcome.eventId
			playedOdds: bet.playedOdds
			stake: bet.stake
			live: outcome.live
			eventName: outcome.eventName
			criterion: outcome.criterion
			eligibleForCashIn: eligibleForCashIn
	}
