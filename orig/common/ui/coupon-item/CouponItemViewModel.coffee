define (require) ->

	Backbone = require 'lib/backbone'
	ViewModel = require 'common/ViewModel'
	SubscriptionKeys = require 'datacommunication/SubscriptionKeys'

	class CouponItemViewModel extends ViewModel

		id: 'CouponItemViewModel'
		couponId: undefined
		coupon: undefined

		constructor: (@couponId) ->
			super
			@coupon = new Backbone.Model()
			@couponOutcomes = new Backbone.Collection()
			do @addSubscriptions

		addSubscriptions: ->
			@subscribe SubscriptionKeys.COUPON, @_onCouponChange, { couponId: @couponId }

		postCashIn: ->
			cashInParams =
				betId: @coupon.get 'singleBetId'
				cashInRequest:
					amount: @coupon.get 'cashInAmount'

			@subscribe SubscriptionKeys.COUPON, null, { couponId: @couponId, postParams: cashInParams, method: 'POST' }

		dispose: ->
			do @unsubscribeAll

		_onCouponChange: (coupon) =>
			@couponOutcomes.set coupon.outcomes
			delete coupon.outcomes
			@coupon.set coupon


	return CouponItemViewModel