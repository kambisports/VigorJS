define (require) ->

	BaseOutcomeView = require '../../BaseOutcomeView'
	tmpl = require 'hbs!./templates/BasicOutcome'

	class BasicOutcome extends BaseOutcomeView

		#----------------------------------------------
		# Public methods
		#----------------------------------------------
		addSubscriptions: ->
			super

		removeSubscriptions: ->
			super

		renderStaticContent: ->
			@$el.html tmpl(@model.toJSON())
			super

		renderDynamicContent: ->
			super

		dispose: ->
			super

	return BasicOutcome