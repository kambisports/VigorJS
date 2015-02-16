define (require) ->

	Backbone = require 'lib/backbone'

	class StatisticsModel extends Backbone.Model

		defaults:
			eventId: undefined

		###
			individual sport property, ex
			football: {
				home: {
					corners: #number
					redCards: #number
					yellowCards: #number
				},
				away: {
					corners: #number
					redCards: #number
					yellowCards: #number
				}
			}
		###


	return StatisticsModel