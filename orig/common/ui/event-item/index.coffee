define (require) ->

	PackageBase = require 'common/PackageBase'
	EventItemView = require './BaseEventItemView'
	EventItemModel = require './EventItemModel'

	class EventItem extends PackageBase

		# private properties
		_eventItemView: undefined
		_viewModel: undefined

		# public properties
		eventId: undefined

		constructor: (@eventId) ->
			super
			@_viewModel = new EventItemModel @eventId
			@_eventItemView = new EventItemView
				viewModel: @_viewModel

		render: ->
			do @renderDeferred.resolve
			return @_eventItemView.render().$el

		addBetoffer: (betoffer) ->
			@_eventItemView.addBetoffer betoffer

		dispose: ->
			do @_eventItemView.dispose
			do @_viewModel.dispose

		NAME: 'EventItem'

	return EventItem