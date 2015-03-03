define (require) ->

	$ = require 'jquery'
	ComponentView = require 'common/ComponentView'
	tmpl = require 'hbs!./templates/EventItem'

	class BaseEventItemView extends ComponentView

		className: 'modularized__event-item'
		tagName: 'li'

		viewModel: undefined
		_betoffers: undefined
		$_eventLink: undefined

		#----------------------------------------------
		# Public methods
		#----------------------------------------------
		initialize: ->
			super
			@_betoffers = []
			@listenTo @viewModel.event, 'change', @_onEventChange

		renderStaticContent: ->
			eventData = @viewModel.event.toJSON()
			@$el.html tmpl(eventData)
			@$_eventLink = $ '.modularized__js-event-link', @el
			return

		renderDynamicContent: ->
			eventData = @viewModel.event.toJSON()
			@$_eventLink.replaceWith tmpl(eventData)
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
			do @renderDynamicContent


	return BaseEventItemView