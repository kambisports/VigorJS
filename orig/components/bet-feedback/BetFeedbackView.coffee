define (require) ->

	$ = require 'jquery'
	CouponItem = require 'common/ui/coupon-item'
	ComponentView = require 'common/ComponentView'
	tmpl = require 'hbs!./templates/BetFeedback'
	balanceTmpl = require 'hbs!./templates/BetFeedbackBalance'

	class BetFeedbackView extends ComponentView

		className: 'bet-feedback'

		#--------------------------------------
		#	Private properties
		#--------------------------------------

		# reference to the coupon list
		_coupons: undefined

		#----------------------------------------------
		# Public methods
		#----------------------------------------------
		initialize: ->
			super
			@listenTo @viewModel.user, 'change:balance', @_onUserBalanceChange
			@listenTo @viewModel.coupons, 'add', @_onCouponsAdd
			@listenTo @viewModel.coupons, 'remove', @_onCouponsRemove
			@listenTo @viewModel.coupons, 'sort', @_onSort
			@_coupons = []

		dispose: ->
			super
			do @_disposeCoupons
			@_coupons = undefined
			@$_betFeedbackBalance = undefined
			@$_betFeedbackCoupons = undefined

		renderStaticContent: ->
			@$el.html tmpl()
			@$_betFeedbackBalance = $ '.js-bet-feedback__balance', @el
			@$_betFeedbackCoupons = $ '.js-bet-feedback__coupons', @el

		renderDynamicContent: ->
			return

		addSubscriptions: ->
			do @viewModel.addSubscriptions

		removeSubscriptions: ->
			do @viewModel.removeSubscriptions

		_disposeCoupons: ->
			for coupon in @_coupons
				do coupon.dispose
			@_coupons = []

		_updateBalance: ->
			user = @viewModel.user.toJSON()
			@$_betFeedbackBalance.html balanceTmpl(user)

		# This is done to keep the dom in sync with the backbone collection
		_sortAndRenderCoupons: ->
			@_coupons.sort (a, b) =>
				aModel = @viewModel.coupons.get(a.couponId)
				aIndex = @viewModel.coupons.indexOf aModel

				bModel = @viewModel.coupons.get(b.couponId)
				bIndex = @viewModel.coupons.indexOf bModel
				return aIndex - bIndex


			fragment = window.document.createDocumentFragment()

			for coupon, i in @_coupons
				fragment.appendChild coupon.render().$el[0]

			@$_betFeedbackCoupons.html fragment

		_onUserBalanceChange: ->
			do @_updateBalance

		_onCouponsRemove: (removedItem, collection, options) ->
			removedComponent = @_coupons.splice(options.index, 1)[0]

			if removedComponent
				do removedComponent.$el.remove
				do removedComponent.dispose

		_onCouponsAdd: (couponModel) ->
			@_coupons.push new CouponItem(couponModel.get('id'))

		_onSort: =>
			# In this case we can use sort to render since its allways being triggered after a set
			do @_sortAndRenderCoupons

	BetFeedbackView
