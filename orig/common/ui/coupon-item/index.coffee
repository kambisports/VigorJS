define (require) ->

	PackageBase = require 'common/PackageBase'
	CouponItemView = require './CouponItemView'
	CouponItemViewModel = require './CouponItemViewModel'

	class CouponItem extends PackageBase

		# public properties
		couponId: undefined
		$el: undefined

		# private properties
		_couponItemView: undefined
		_couponItemViewModel: undefined

		constructor: (@couponId) ->
			super
			@_couponItemViewModel = new CouponItemViewModel @couponId
			@_couponItemView = new CouponItemView
				viewModel: @_couponItemViewModel
			@$el = @_couponItemView.$el

		render: ->
			@_couponItemView.render()
			do @renderDeferred.resolve
			return @

		dispose: ->
			do @_couponItemView.dispose
			do @_couponItemViewModel.dispose
			do @$el.remove

		NAME: 'CouponItem'

	return CouponItem