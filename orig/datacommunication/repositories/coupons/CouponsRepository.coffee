define (require) ->

	ServiceRepository = require 'datacommunication/repositories/ServiceRepository'

	# services that receives data for this repo
	CouponService = require 'datacommunication/apiservices/CouponService'
	CashinCouponService = require 'datacommunication/apiservices/CashinCouponService'

	# the repo holds a collection of this model type
	CouponModel = require 'datacommunication/repositories/coupons/CouponModel'

	class CouponRepository extends ServiceRepository

		model: CouponModel

		ALL: 'all'
		CASHIN_COUPON: 'cashin-coupon'

		services:
			'all': CouponService
			'cashin-coupon': CashinCouponService

		initialize: ->
			CouponService.on CouponService.COUPONS_RECIEVED, @_onCouponRecieved
			super

		getCoupons: ->
			return @models

		_onCouponRecieved: (couponData) =>
			@set couponData, { remove: true }

		makeTestInstance: ->
			new CouponRepository()

	new CouponRepository()
