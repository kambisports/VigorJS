define (require) ->

	ServiceRepository = require 'datacommunication/repositories/ServiceRepository'
	CouponOutcomeModel = require './CouponOutcomeModel'

	# services that receives data for this repo
	CouponService = require 'datacommunication/apiservices/CouponService'

	class CouponOutcomesRepository extends ServiceRepository

		model: CouponOutcomeModel

		ALL: 'all'

		services:
			'all': CouponService

		initialize: ->
			CouponService.on CouponService.COUPON_OUTCOMES_RECIEVED, @_onCouponOutcomeRecieved
			super

		getCouponOucomesByOutcomeId: (outcomeId) ->
			return @where { 'outcomeId': outcomeId }

		getOucomesByBetofferId: (betofferId) ->
			return @where { 'betofferId': betofferId }

		getOutcomesByCouponId: (couponId) ->
			return @where { 'couponId': couponId }

		getOutcomesEligibleForCashin: ->
			return @where { 'eligibleForCashIn': true }

		getOutcomesEligibleForCashinByOutcomeIds: (outcomeIds) ->
			eligibleCouponOutcomes = _.filter @eligibleCouponOutcomes(), (outcome) ->
				outcomeIds.indexOf(outcome.get('outcomeId')) isnt -1
			return eligibleCouponOutcomes

		_onCouponOutcomeRecieved: (couponOutcomes) =>
			@set couponOutcomes, { remove: false }

	new CouponOutcomesRepository()
