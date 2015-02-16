define (require) ->

	BaseOutcomeView = require '../../BaseOutcomeView'
	tmpl = require 'hbs!./templates/NoLabelOutcome'

	class NoLabelOutcomeView extends BaseOutcomeView

		className: 'modularized__outcome modularized__js-outcome modularized-outcome--no-label'
		#----------------------------------------------
		# Public methods
		#----------------------------------------------

		addSubscriptions: ->
			super

		removeSubscriptions: ->
			super

		render: ->
			@$el.html tmpl(@model.toJSON())
			super
			return @

		renderStaticContent: ->
			super

		renderDynamicContent: ->
			super

		dispose: ->
			super

	return NoLabelOutcomeView