define (require) ->

	_ = require 'lib/underscore'
	PackageBase = require 'common/PackageBase'
	HighlightedListModel = require './types/highlighted/HighlightedListModel'
	HighlightedListView = require './types/highlighted/HighlightedListView'
	SportsListModel = require './types/sports/SportsListModel'
	SportsListView = require './types/sports/SportsListView'
	RacingListModel = require './types/racing/RacingListModel'
	RacingListView = require './types/racing/RacingListView'
	RacingSportsListModel = require './types/racing-sports/RacingSportsListModel'
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

			ViewClass = @_getViewClass(options.type)
			@_view = new ViewClass
				viewModel: @_model

		render: ->
			@$el = @_view.render().$el
			#TODO
			#_.defer =>
			#	do @renderDeferred.resolve
			return @

		# Exposes the group list header to outside of component.
		getHeader: () ->
			@_model.getHeader()

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
					Class = SportsListModel
				when 'highlighted'
					Class = HighlightedListModel
				when 'racing'
					Class = RacingListModel
				when 'racing-sports'
					Class = RacingSportsListModel

			return Class

		GroupList.NAME = 'GroupList'

	return GroupList