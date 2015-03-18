define (require) ->

	PackageBase = require 'common/PackageBase'
	EventItemView = require './BaseEventItemView'
	EventItemViewModel = require './EventItemViewModel'

	class EventItem extends PackageBase

		# private properties
		_eventItemView: undefined
		_viewModel: undefined

		# public properties
		$el: undefined
		eventId: undefined

		constructor: (@eventId) ->
			super
			@_viewModel = new EventItemViewModel @eventId
			@_eventItemView = new EventItemView
				viewModel: @_viewModel
			@$el = @_eventItemView.$el

		render: ->
			do @renderDeferred.resolve
			@_eventItemView.render()
			return @

		addBetoffer: (betoffer) ->
			@_eventItemView.addBetoffer betoffer

		dispose: ->
			do @_eventItemView.dispose
			do @_viewModel.dispose

		NAME: 'EventItem'

	return EventItem