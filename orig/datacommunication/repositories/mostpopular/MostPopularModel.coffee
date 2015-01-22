define (require) ->

	Backbone = require 'lib/backbone'

	class MostPopularModel extends Backbone.Model

		defaults:
			eventId: undefined
			betofferId: undefined
			outcomeId: undefined
			outcomeOdds: undefined

	return MostPopularModel