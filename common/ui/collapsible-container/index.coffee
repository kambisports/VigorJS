define (require) ->

	_ = require 'lib/underscore'
	PackageBase = require 'common/PackageBase'
	CollapsibleContainerView = require './CollapsibleContainerView'
	CollapsibleContainerModel = require './CollapsibleContainerModel'

	class CollapsibleContainer extends PackageBase

		title: undefined

		_groupItemModel: undefined
		_groupItemView: undefined

		constructor: (@title) ->
			super

			@_groupItemModel = new CollapsibleContainerModel
				title: @title

			ContainerClass = @_getContainerClass()
			@_groupItemView = new ContainerClass
				viewModel: @_groupItemModel


		render: ->
			@$el = @_groupItemView.render().$el
			_.defer =>
				do @renderDeferred.resolve
			return @


		setContent: (content) ->
			@_groupItemView.setContent content


		dispose: ->
			do @_groupItemView.dispose
			do @_groupItemModel.dispose
			@_groupItemView = undefined
			@_groupItemModel = undefined


		_getContainerClass: ->
			ContainerView = CollapsibleContainerView
			#TODO Logics for selecting collapsible container type
			return ContainerView


		CollapsibleContainer.NAME = 'CollapsibleContainer'

	return CollapsibleContainer
