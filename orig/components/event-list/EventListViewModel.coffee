define (require) ->

	Backbone = require 'lib/backbone'
	ViewModel = require 'common/ViewModel'
	SubscriptionKeys = require 'datacommunication/SubscriptionKeys'

	class EventListViewModel extends ViewModel

		id: 'EventListViewModel'

		# collection with all groups
		eventCollection: undefined


		#----------------------------------------------
		# Public methods
		#----------------------------------------------

		constructor: (options) ->
			@eventCollection = new Backbone.Collection()
			super

		addSubscriptions: ->
			@subscribe SubscriptionKeys.LIVE_EVENTS, @_onLiveEvents, {}

		removeSubscriptions: ->
			@unsubscribe SubscriptionKeys.LIVE_EVENTS

		#----------------------------------------------
		# Callbacks
		#----------------------------------------------
		_onLiveEvents: (jsonData) ->
			console.log '_onLiveEvents view model callback', jsonData


	return EventListViewModel