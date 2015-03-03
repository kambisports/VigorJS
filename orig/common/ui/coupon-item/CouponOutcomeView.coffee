define (require) ->

	$ = require 'jquery'
	ComponentView = require 'common/ComponentView'
	outcomeTmpl = require 'hbs!./templates/CouponOutcome'

	class CouponOutcomeView extends ComponentView

		className: 'modularized__coupon-outcome'
		tagName: 'li'

		#----------------------------------------------
		# Public methods
		#----------------------------------------------
		initialize: ->
			super
			@listenTo @model, 'change', @renderDynamicContent

		renderStaticContent: ->
			@$el.html outcomeTmpl(@model.toJSON())
			return

		renderDynamicContent: =>
			@$el.html outcomeTmpl(@model.toJSON())
			return

		addSubscriptions: ->
			return

		removeSubscriptions: ->
			return

		dispose: ->
			super

		#----------------------------------------------
		# Callbacks
		#----------------------------------------------


	return CouponOutcomeView