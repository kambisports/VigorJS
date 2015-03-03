define (require) ->

	$ = require 'jquery'
	KambiApiService = require 'datacommunication/apiservices/KambiApiService'
	CouponParser = require 'datacommunication/apiservices/parsers/CouponParser'
	OutcomeParser = require 'datacommunication/apiservices/parsers/OutcomeParser'
	CouponOutcomeParser = require 'datacommunication/apiservices/parsers/CouponOutcomeParser'

	class CouponService extends KambiApiService

		requiresAuthentication: true

		parse: (response) =>
			couponOutcomes = []
			coupons = []
			_.each response.historySummaryCoupons, (coupon) ->
				parsedCoupon = CouponParser.parse coupon
				coupons.push parsedCoupon

				_.each coupon.outcomes, (outcome, index) ->
					bet = coupon.bets?[index] or coupon
					couponOutcomes.push CouponOutcomeParser.parse coupon, outcome, bet, parsedCoupon.eligibleForCashIn

			@propagateResponse @COUPONS_RECIEVED, coupons
			@propagateResponse @COUPON_OUTCOMES_RECIEVED, couponOutcomes

		queryParams: (model) ->
			params = super
			return _.extend params, model.toJSON()

		urlPath: (model) ->
			return '/coupon/summary.json'

		COUPONS_RECIEVED: 'coupons-recieved'
		COUPON_OUTCOMES_RECIEVED: 'coupon-outcome-recieved'

	new CouponService()
