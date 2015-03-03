define (require) ->

	_ = require 'lib/underscore'
	PackageBase = require 'common/PackageBase'
	EventListView = require './EventListView'
	EventListViewModel = require './EventListViewModel'

	class EventList extends PackageBase

		$el: undefined

		_eventListView: undefined
		_eventCollection: undefined

		#----------------------------------------------
		# Public methods
		#----------------------------------------------
		constructor: ->
			super

			@_eventCollection = new EventListViewModel()
			@_eventListView = new EventListView
				viewModel: @_eventCollection

		render: ->
			@$el = @_eventListView.render().$el

			_.defer =>
				do @renderDeferred.resolve

			return @

		# Exposes the group list header to outside of component.
		getHeader: () ->
			'LIVE-RIGHT-NOW' + ' [TCMOD]'#TODO remove

		dispose: ->
			do @_eventListView.dispose
			do @_eventCollection.dispose

			@_eventListView = undefined
			@_eventCollection = undefined

		NAME: 'EventList'

	return EventList