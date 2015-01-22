define (require) ->

	_ = require 'lib/underscore'
	PackageBase = require 'common/PackageBase'
	BrowseHighlightedView = require './BrowseHighlightedView'
	BrowseHighlightedViewModel = require './BrowseHighlightedViewModel'

	class BrowseHighlighted extends PackageBase

		$el: undefined
		_viewModel: undefined
		_browseHighlightedView: undefined

		constructor: ->
			super
			@_viewModel = new BrowseHighlightedViewModel()
			@_browseHighlightedView = new BrowseHighlightedView
				viewModel: @_viewModel

		render: ->
			@$el = @_browseHighlightedView.render().$el
			_.defer =>
				do @renderDeferred.resolve
			return @

		dispose: =>
			do @_browseHighlightedView.dispose
			@_browseHighlightedView = undefined
			@_viewModel = undefined
			super

		BrowseHighlighted.NAME = 'BrowseHighlighted'

	return BrowseHighlighted
