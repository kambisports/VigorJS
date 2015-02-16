define (require) ->

	Backbone = require 'lib/backbone'

	class ScoreModel extends Backbone.Model

		defaults:
			eventId: undefined #number
			who: undefined #string
			away: undefined #string
			home: undefined #string


	return ScoreModel