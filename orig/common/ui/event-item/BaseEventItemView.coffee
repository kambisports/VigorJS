define (require) ->

	ComponentView = require 'common/ComponentView'
	tmpl = require 'hbs!./templates/EventItem'

	class BaseEventItemView extends ComponentView

		className: 'modularized__event-item'
		tagName: 'li'

		viewModel: undefined
		_betoffers: undefined

		#----------------------------------------------
		# Public methods
		#----------------------------------------------
		initialize: ->
			super
			@_betoffers = []
			@listenTo @viewModel.event, 'change', @_onEventChange

		render: ->
			templateData = @viewModel.event.toJSON()
			templateData.awayName = templateData.awayName
			templateData.homeName = templateData.homeName

			@$el.html tmpl(templateData)

			@renderDeferred.resolve @
			return @

		renderStaticContent: ->
			return

		renderDynamicContent: ->
			return

		addSubscriptions: ->
			return

		removeSubscriptions: ->
			return

		addBetoffer: (betoffer) ->
			@_betoffers.push betoffer
			betoffer.render().then ($el) =>
				@$el.find('.modularized__js-outcomes-container').remove()
				@$el.append $el

		dispose: ->
			for betoffer in @_betoffers
				do betoffer.dispose
			super

		#----------------------------------------------
		# Callbacks
		#----------------------------------------------
		_onEventChange: ->
			do @render


	return BaseEventItemView