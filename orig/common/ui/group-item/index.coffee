define (require) ->

	_ = require 'lib/underscore'
	PackageBase = require 'common/PackageBase'
	GroupItemView = require './GroupItemView'
	GroupItemModel = require './GroupItemModel'

	###
		This ui component does not have its own Producer, so
		it must be populated with data from parent component.
	###
	class GroupItem extends PackageBase

		# private properties
		_groupItemModel: undefined
		_groupItemView: undefined

		#----------------------------------------------
		# Public methods
		#----------------------------------------------
		constructor: (group) ->
			super

			@_groupItemModel = new GroupItemModel group

			@_groupItemView = new GroupItemView
				viewModel: @_groupItemModel

			@$el = @_groupItemView.$el

		render: ->
			@_groupItemView.render()
			_.defer =>
				do @renderDeferred.resolve
			return @


		dispose: ->
			do @_groupItemView?.dispose
			@_groupItemView = undefined

			do @_groupItemModel?.dispose
			@_groupItemModel = undefined

		NAME: 'GroupItem'

	return GroupItem
