define (require) ->

	Backbone = require 'lib/backbone'

	class EventModel extends Backbone.Model

		defaults:
			id: undefined # number
			homeName: undefined #string
			awayName: undefined #string
			group: undefined #string
			url: undefined #string
			divider: '-' #string

	return EventModel