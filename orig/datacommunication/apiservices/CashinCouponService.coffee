define (require) ->

	KambiApiService = require 'datacommunication/apiservices/KambiApiService'

	class CouponService extends KambiApiService

		requiresAuthentication: true

		queryParams: (model) ->
			params = super
			return _.extend params, model.toJSON()

		urlPath: (model) ->
			return "/coupon/bet/#{model.get('betId')}/cashIn.json"

	new CouponService()
