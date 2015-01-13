define (require) ->

	$ = require 'jquery'
	Backbone = require 'lib/backbone'
	ComponentView = require 'common/ComponentView'

	tmpl = require 'hbs!./templates/EventItem'

	class BaseEventItemView extends ComponentView

		className: 'modularized__event-item'
		tagName: 'li'

		betoffers: undefined

		#----------------------------------------------
		# Public methods
		#----------------------------------------------
		initialize: ->
			super
			@betoffers = []
			@listenTo @viewModel.event, 'change', @_onEventChange

		render: ->
			templateData = @viewModel.event.toJSON()
			templateData.awayName = templateData.awayName
			templateData.homeName = templateData.homeName

			@$el.html tmpl(templateData)
			@renderDeferred.resolve @
			return @

		addBetoffer: (betoffer) ->
			@betoffers.push betoffer
			betoffer.render().then ($el) =>
				@$el.find('.modularized__outcomes-container').remove()
				@$el.append $el

		dispose: ->
			for betoffer in @betoffers
				do betoffer.dispose
			super

		#----------------------------------------------
		# Private methods
		#----------------------------------------------

		#----------------------------------------------
		# Callbacks
		#----------------------------------------------
		_onEventChange: ->
			do @render


	return BaseEventItemView