define (require) ->

	_ = require 'lib/underscore'
	PackageBase = require 'common/PackageBase'
	CollapsibleContainerView = require './CollapsibleContainerView'
	CollapsibleContainerModel = require './CollapsibleContainerModel'

	class CollapsibleContainer extends PackageBase

		title: undefined

		_containerModel: undefined
		_containerView: undefined

		constructor: (@title) ->
			super

			@_containerModel = new CollapsibleContainerModel
				title: @title

			ViewClass = @_getViewClass()
			@_containerView = new ViewClass
				viewModel: @_containerModel


		render: ->
			@$el = @_containerView.render().$el
			_.defer =>
				do @renderDeferred.resolve
			return @


		setContent: (content) ->
			@_containerView.setContent content


		dispose: ->
			do @_containerView.dispose
			do @_containerModel.dispose
			@_containerView = undefined
			@_containerModel = undefined


		_getViewClass: ->
			ViewClass = CollapsibleContainerView
			#TODO Logics for selecting collapsible container type
			return ViewClass


		NAME: 'CollapsibleContainer'

	return CollapsibleContainer
