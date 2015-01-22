define (require) ->

	BaseOutcomeView = require '../../BaseOutcomeView'
	tmpl = require 'hbs!./templates/NoLabelOutcome'

	class NoLabelOutcomeView extends BaseOutcomeView

		className: 'modularized__outcome no-label'
		#----------------------------------------------
		# Public methods
		#----------------------------------------------

		render: ->
			@$el.html tmpl(@model.toJSON())
			super
			return @

	return NoLabelOutcomeView