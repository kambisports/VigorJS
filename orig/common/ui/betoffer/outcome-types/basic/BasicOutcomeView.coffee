define (require) ->

	BaseOutcomeView = require '../../BaseOutcomeView'
	tmpl = require 'hbs!./templates/BasicOutcome'

	class BasicOutcome extends BaseOutcomeView

		#----------------------------------------------
		# Public methods
		#----------------------------------------------

		render: ->
			@$el.html tmpl(@model.toJSON())
			super
			return @


	return BasicOutcome