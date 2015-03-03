define (require) ->

	_ = require 'lib/underscore'

	AppConstants = require 'AppConstants'
	BetOffer = require 'model/BetOffer'

	CouponOutcomesRepository = require 'datacommunication/repositories/coupon-outcomes/CouponOutcomesRepository'
	OutcomesRepository = require 'datacommunication/repositories/outcomes/OutcomesRepository'
	BetoffersRepository = require 'datacommunication/repositories/betoffers/BetoffersRepository'

	getCashInAmount: (coupon) ->

		unless coupon.eligibleForCashIn then return
		couponOutcomes = CouponOutcomesRepository.getOutcomesByCouponId(coupon.id)

		playedOutcome = couponOutcomes[0]
		betoffer = BetoffersRepository.get playedOutcome.get('betofferId')
		unless betoffer then return
		if betoffer.get('closed') or betoffer.get('suspended') then return

		betofferOutcomes = OutcomesRepository.getOutcomesByBetofferId betoffer.get('id')
		stake = coupon.stake
		playedOdds = coupon.playedOdds
		outcome = _.find betofferOutcomes, (betofferOutcome) ->
			return betofferOutcome.get('id') is playedOutcome.get('outcomeId')

		unless outcome then return
		currentOdds = outcome.get('odds')

		invertedSumOfOdds = 1 / (_.reduce betofferOutcomes, (memo, outcome) ->
			memo + (1000 / outcome.get('odds'))
		, 0)

		oddsChangeRatio = playedOdds / currentOdds

		cashInAmount = stake * \
			oddsChangeRatio * \
			AppConstants.CASH_IN_PAYBACK_FACTOR * \
			invertedSumOfOdds

		if (betoffer.get 'betofferType').id is BetOffer.TYPE_DOUBLE_CHANCE
			cashInAmount *= 2

		return 10 * Math.round (cashInAmount / 10)

