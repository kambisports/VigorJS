define (require) ->

	Backbone = require 'lib/backbone'

	class CouponModel extends Backbone.Model

		defaults:
			id: undefined
			placedDate: undefined
			distinctBetStatuses: []
			singleBetId: undefined
			betsPattern: undefined
			eligibleForCashIn: undefined
			currency: undefined
			euroStake: undefined
			playedOdds: undefined
			potentialPayout: undefined
			requestedStake: undefined
			stake: undefined

	return CouponModel
