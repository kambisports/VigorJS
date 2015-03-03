define (require) ->

	Backbone = require 'lib/backbone'

	class CouponOutcomeModel extends Backbone.Model

		defaults:
			id: undefined
			couponId: undefined
			outcomeId: undefined
			betofferId: undefined
			eventId: undefined
			playedOdds: undefined
			stake: undefined
			live: undefined
			eventName: undefined
			criterion: undefined

	return CouponOutcomeModel
