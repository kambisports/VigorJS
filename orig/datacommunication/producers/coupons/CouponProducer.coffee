define (require) ->

	Producer = require 'datacommunication/producers/Producer'
	SubscriptionKeys = require 'datacommunication/SubscriptionKeys'

	CouponsRepository = require 'datacommunication/repositories/coupons/CouponsRepository'
	CouponOutcomesRepository = require 'datacommunication/repositories/coupon-outcomes/CouponOutcomesRepository'
	OutcomesRepository = require 'datacommunication/repositories/outcomes/OutcomesRepository'
	BetoffersRepository = require 'datacommunication/repositories/betoffers/BetoffersRepository'

	# Mixins
	getCashInAmount = require 'datacommunication/producers/mixins/getCashInAmountMixin'

	class CouponProducer extends Producer

		constructor: ->
			super
			OutcomesRepository.on OutcomesRepository.REPOSITORY_DIFF, @_onDiffInOutcomeRepository, @
			BetoffersRepository.on BetoffersRepository.REPOSITORY_DIFF, @_onDiffInBetofferRepository, @
			CouponsRepository.on CouponsRepository.REPOSITORY_DIFF, @_onDiffInRepository, @
			CouponOutcomesRepository.on CouponOutcomesRepository.REPOSITORY_DIFF, @_onDiffInCouponOutcomesRepository, @
			@mixin @, getCashInAmount

		dispose: ->
			OutcomesRepository.off OutcomesRepository.REPOSITORY_DIFF, @_onDiffInOutcomeRepository, @
			BetoffersRepository.off BetoffersRepository.REPOSITORY_DIFF, @_onDiffInBetofferRepository, @
			CouponsRepository.off CouponsRepository.REPOSITORY_DIFF, @_onDiffInRepository, @
			CouponOutcomesRepository.off CouponOutcomesRepository.REPOSITORY_DIFF, @_onDiffInCouponOutcomesRepository, @
			super

		subscribe: (subscriptionKey, options) ->
			model = CouponsRepository.get options.couponId
			if options.postParams
				CouponsRepository.addSubscription CouponsRepository.CASHIN_COUPON, options

			@_produceData [model]

		# ------------------------------------------------------------------------------------------------
		_produceData: (coupons = []) ->
			unless coupons.length > 0 then return

			coupons = _.without coupons, undefined
			coupons = @modelsToJSON coupons

			for coupon in coupons
				coupon = @_buildData coupon
				@produce SubscriptionKeys.COUPON, coupon, (componentOptions) ->
					coupon.id is componentOptions.couponId

		_buildData: (coupon) ->
			coupon.cashInAmount = @getCashInAmount coupon
			couponOutcomes = CouponOutcomesRepository.getOutcomesByCouponId(coupon.id)
			coupon.outcomes = @modelsToJSON couponOutcomes
			return coupon


		# ------------------------------------------------------------------------------------------------
		_onDiffInRepository: (dataDiff) ->
			if dataDiff.consolidated.length > 0
				@_produceData dataDiff.consolidated

		_onDiffInCouponOutcomesRepository: (dataDiff) ->
			if dataDiff.consolidated.length > 0
				coupons = []
				for outcome in dataDiff.consolidated
					coupons.push CouponsRepository.get outcome.get('couponId')
				@_produceData coupons

		_onDiffInBetofferRepository: (dataDiff) =>
			for betoffer in dataDiff.consolidated
				couponOutcomes = CouponOutcomesRepository.getOucomesByBetofferId(betoffer.get('id'))
				for couponOutcome in couponOutcomes
					coupon = CouponsRepository.get couponOutcome.get('couponId')
					@_produceData [coupon]

		_onDiffInOutcomeRepository: (dataDiff) =>
			for outcome in dataDiff.consolidated
				couponOutcomes = CouponOutcomesRepository.getCouponOucomesByOutcomeId(outcome.get('id'))
				for couponOutcome in couponOutcomes
					coupon = CouponsRepository.get couponOutcome.get('couponId')
					@_produceData [coupon]


		SUBSCRIPTION_KEYS: [SubscriptionKeys.COUPON]
		NAME: 'CouponProducer'