define (require) ->

	_ = require 'lib/underscore'
	PackageBase = require 'common/PackageBase'
	HighlightedListModel = require './types/HighlightedListModel'
	HighlightedListView = require './types/HighlightedListView'
	SportsListModel = require './types/SportsListModel'
	SportsListView = require './types/SportsListView'

	class GroupList extends PackageBase

		$el: undefined
		# private properties
		_groupListModel: undefined
		_groupListView: undefined
		_type: undefined
		_sortingMethod: undefined

		#----------------------------------------------
		# Public methods
		#----------------------------------------------
		constructor: (options) ->
			super

			@_type = options.type
			@_sortingMethod = options.sortingMethod

			ModelClass = @_getModelClass(@_type)
			@_groupListModel = new ModelClass

			ViewClass = @_getViewClass(@_type)
			@_groupListView = new ViewClass
				viewModel: @_groupListModel
				sortingMethod: @_sortingMethod

		render: ->
			@$el = @_groupListView.render().$el
			#_.defer =>
			#	do @renderDeferred.resolve
			return @


		dispose: ->
			do @_groupListView.dispose
			do @_groupListModel.dispose
			@_groupListView = undefined
			@_groupListModel = undefined

		_getViewClass: (type) ->
			switch type
				when 'Sports'
					ViewClass = SportsListView
				when 'Highlighted'
					ViewClass = HighlightedListView

			return ViewClass

		_getModelClass: (type) ->
			switch type
				when 'Sports'
					ModelClass = SportsListModel
				when 'Highlighted'
					ModelClass = HighlightedListModel

			return ModelClass


		GroupList.NAME = 'GroupList'

	return GroupList