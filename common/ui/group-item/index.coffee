define (require) ->

	_ = require 'lib/underscore'
	PackageBase = require 'common/PackageBase'
	GroupItemView = require './GroupItemView'
	GroupItemModel = require './GroupItemModel'

	class GroupItem extends PackageBase

		# private properties
		_groupItemModel: undefined
		_groupItemView: undefined

		groupId: undefined

		#----------------------------------------------
		# Public methods
		#----------------------------------------------
		constructor: (@groupId) ->
			super

			@_groupItemModel = new GroupItemModel @groupId
			@_groupItemView = new GroupItemView
				viewModel: @_groupItemModel


		render: ->
			@$el = @_groupItemView.render().$el
			_.defer =>
				do @renderDeferred.resolve
			return @


		dispose: ->
			do @_groupItemView?.dispose
			do @_groupItemModel?.dispose
			@_groupItemView = undefined
			@_groupItemModel = undefined

		GroupItem.NAME = 'GroupItem'

	return GroupItem
