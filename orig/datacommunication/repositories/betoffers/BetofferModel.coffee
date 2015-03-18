define (require) ->

	Backbone = require 'lib/backbone'

	class BetofferModel extends Backbone.Model

		defaults:
			id: undefined
			eventId: undefined
			betofferType: undefined #object
			categoryName: undefined
			closed: undefined
			criterion: undefined #object
			main: undefined
			suspended: undefined

	return BetofferModel