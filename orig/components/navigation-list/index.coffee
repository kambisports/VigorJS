define (require) ->

	_ = require 'lib/underscore'
	PackageBase = require 'common/PackageBase'
	BrowseListView = require './BrowseListView'
	BrowseGeneralViewModel = require './BrowseGeneralViewModel'
	BrowseHighlightedViewModel = require './BrowseHighlightedViewModel'
	BrowseSportsViewModel = require './BrowseSportsViewModel'

	class BrowseHighlighted extends PackageBase

		$el: undefined
		_viewModel: undefined
		_browseHighlightedView: undefined

		constructor: (options) ->
			super
			ModelClass = @_getModelClass(options.type)
			@_viewModel = new ModelClass(options)

			@_browseHighlightedView = new BrowseListView
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

		_getModelClass: (type) ->
			switch type
				when 'highlighted'
					ModelClass =  BrowseHighlightedViewModel
				when 'sports'
					ModelClass = BrowseSportsViewModel
				when 'general'
					ModelClass = BrowseGeneralViewModel

			return ModelClass

		NAME: 'BrowseHighlighted'

	return BrowseHighlighted
