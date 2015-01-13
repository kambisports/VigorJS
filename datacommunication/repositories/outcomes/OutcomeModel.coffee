define (require) ->

	Backbone = require 'lib/backbone'

	class OutcomeModel extends Backbone.Model

		defaults:
			id: undefined
			betofferId: undefined
			changedDate: undefined
			label: undefined
			odds: undefined
			oddsAmerican: undefined
			oddsFractional: undefined
			popular: undefined
			type: undefined

	return OutcomeModel