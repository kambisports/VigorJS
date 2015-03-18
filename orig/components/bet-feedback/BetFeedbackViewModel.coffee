define (require) ->

	Backbone = require 'lib/backbone'
	ViewModel = require 'common/ViewModel'
	SubscriptionKeys = require 'datacommunication/SubscriptionKeys'

	class BetFeedbackViewModel extends ViewModel
		# A CouponCollection
		coupons: undefined

		# A UserModel
		user: undefined

		constructor: ->
			@user = new Backbone.Model()
			@coupons = new Backbone.Collection()

		addSubscriptions: ->
			@subscribe SubscriptionKeys.USER, @_onNewUserData, {}
			@subscribe SubscriptionKeys.BETFEEDBACK, @_onNewBetFeedbackData, {}

		removeSubscriptions: ->
			@unsubscribe SubscriptionKeys.USER
			@unsubscribe SubscriptionKeys.BETFEEDBACK

		#----------------------------------------------
		# Callbacks
		#----------------------------------------------
		_onNewUserData: (userData) =>
			@user.set userData

		_onNewBetFeedbackData: (coupons) =>
			@coupons.set coupons

	return BetFeedbackViewModel
