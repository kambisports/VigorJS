define (require) ->

	$ = require 'jquery'
	ComponentView = require 'common/ComponentView'
	CouponOutcomeView = require './CouponOutcomeView'
	tmpl = require 'hbs!./templates/CouponItem'
	couponInfoTmpl = require 'hbs!./templates/CouponItemInformation'

	class CouponItemView extends ComponentView

		className: 'modularized__coupon-item'
		tagName: 'li'

		events:
			'click .js-cash-in': '_onCashInClick'

		viewModel: undefined
		$_couponOutcomes: undefined


		#----------------------------------------------
		# Public methods
		#----------------------------------------------
		initialize: ->
			super
			@listenTo @viewModel.coupon, 'change', @_onCouponChange

		renderStaticContent: ->
			@$el.html tmpl(@viewModel.coupon.toJSON())
			@$_couponOutcomes = $ '.js-coupon-item__outcomes', @el
			@$_couponInformation = $ '.js-coupon-item__information', @el

			do @_renderCouponInformation
			do @_renderCouponOutcomes
			return

		renderDynamicContent: ->
			return

		addSubscriptions: ->
			return

		removeSubscriptions: ->
			return

		dispose: ->
			super
			do @$el.remove
			@$_couponOutcomes = undefined

		_renderCouponInformation: ->
			couponData = @viewModel.coupon.toJSON()
			@$_couponInformation.html couponInfoTmpl(couponData)

		_renderCouponOutcomes: ->
			for outcomeModel in @viewModel.couponOutcomes.models
				outcomeView = new CouponOutcomeView
					model: outcomeModel

				@$_couponOutcomes.append outcomeView.render().$el

		_cashIn: ->
			@viewModel.postCashIn()

		#----------------------------------------------
		# Callbacks
		#----------------------------------------------
		_onCashInClick: (event) =>
			$btn = $ event.currentTarget
			do $btn.remove
			do @_cashIn

		_onCouponChange: () =>
			do @_renderCouponInformation

	return CouponItemView