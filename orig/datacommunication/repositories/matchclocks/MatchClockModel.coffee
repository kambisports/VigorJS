define (require) ->

	Backbone = require 'lib/backbone'

	class MatchClockModel extends Backbone.Model

		defaults:
			eventId: undefined
			running: undefined #boolean
			period: undefined #string
			minute: undefined #number
			second: undefined #number


	return MatchClockModel