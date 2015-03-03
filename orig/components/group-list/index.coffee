define (require) ->

	_ = require 'lib/underscore'
	PackageBase = require 'common/PackageBase'
	HighlightedListViewModel = require './types/highlighted/HighlightedListViewModel'
	HighlightedListView = require './types/highlighted/HighlightedListView'
	SportsListViewModel = require './types/sports/SportsListViewModel'
	SportsListView = require './types/sports/SportsListView'
	RacingListViewModel = require './types/racing/RacingListViewModel'
	RacingListView = require './types/racing/RacingListView'
	RacingSportsListViewModel = require './types/racing-sports/RacingSportsListViewModel'
	RacingSportsListView = require './types/racing-sports/RacingSportsListView'

	class GroupList extends PackageBase

		$el: undefined

		_model: undefined

		_view: undefined

		#----------------------------------------------
		# Public methods
		#----------------------------------------------
		constructor: (options) ->
			super

			ModelClass = @_getModelClass(options.type)
			@_model = new ModelClass
				sortingMethod: options.sortingMethod
				forceExpand: options.forceExpand

			ViewClass = @_getViewClass(options.type)
			@_view = new ViewClass
				viewModel: @_model

		render: ->
			@$el = @_view.render().$el

			_.defer =>
				do @renderDeferred.resolve

			return @

		# Exposes the group list header to outside of component.
		getHeader: () ->
			@_model.getHeader() + ' [TCMOD]'#TODO remove

		dispose: ->
			do @_view.dispose
			do @_model.dispose
			@_view = undefined
			@_model = undefined

		# Return model class for the specified type.
		_getViewClass: (type) ->
			switch type
				when 'sports'
					Class = SportsListView
				when 'highlighted'
					Class = HighlightedListView
				when 'racing'
					Class = RacingListView
				when 'racing-sports'
					Class = RacingSportsListView

			return Class

		# Return view class for the specified type.
		_getModelClass: (type) ->
			switch type
				when 'sports'
					Class = SportsListViewModel
				when 'highlighted'
					Class = HighlightedListViewModel
				when 'racing'
					Class = RacingListViewModel
				when 'racing-sports'
					Class = RacingSportsListViewModel

			return Class

		NAME: 'GroupList'

	return GroupList