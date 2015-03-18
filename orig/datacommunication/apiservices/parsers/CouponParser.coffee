define (require) ->

	BetHistoryUtil = require 'utils/BetHistoryUtil'

	isEligible = (coupon) ->
		status = BetHistoryUtil.getStatus coupon.distinctBetStatuses
		if coupon.outcomes.length isnt 1 then return false
		if status isnt BetHistoryUtil.HISTORY_COUPON_STATUS_PENDING then return false
		return coupon.outcomes[0].live? and coupon.outcomes[0].live

	isAwaitingApproval = (coupon) ->
		status = BetHistoryUtil.getStatus coupon.distinctBetStatuses
		return status isnt BetHistoryUtil.HISTORY_COUPON_STATUS_PENDING

	{
		parse: (coupon) ->
			id: coupon.id
			placedDate: coupon.placedDate
			distinctBetStatuses: coupon.distinctBetStatuses
			singleBetId: coupon.singleBetId
			betsPattern: coupon.betsPattern
			eligibleForCashIn: isEligible(coupon)
			currency: coupon.currency
			euroStake: coupon.euroStake
			playedOdds: coupon.playedOdds
			potentialPayout: coupon.potentialPayout
			requestedStake: coupon.requestedStake
			stake: coupon.stake
			isAwaitingApproval: isAwaitingApproval(coupon)
	}
