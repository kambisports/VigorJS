define (require) ->

	Backbone = require 'lib/backbone'

	class EventModel extends Backbone.Model

		defaults:
			id: undefined # number
			homeName: undefined #string
			awayName: undefined #string
			group: undefined #string
			url: undefined #string
			englishName: undefined #string
			groupId: undefined #number
			hideStartNo: undefined #boolean
			liveBetOffers: undefined #boolean
			name: undefined #string
			open: undefined #boolean from liveData property on live events
			openForLiveBetting: undefined #boolean
			path: undefined #array
			sport: undefined #string
			sportId: undefined #number
			start: undefined #string "2015-02-10T23:00Z"
			state: undefined #string "NOT_STARTED" "STARTED" "FINISHED"
			streams: undefined #array
			type: undefined #string

			divider: '-' #string

	return EventModel