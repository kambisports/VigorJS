define (require) ->

	$ = require 'jquery'
	_ = require 'lib/underscore'
	EventBus = require 'common/EventBus'
	EventKeys = require 'datacommunication/EventKeys'
	ComponentView = require 'common/ComponentView'
	navTemplate = require 'hbs!./templates/navigation-menu-template'

	class NavigationView extends ComponentView

		tagName: 'aside'
		className: 'modularized__navigation navigation-menu-view'

		#--------------------------------------
		#	Private properties
		#--------------------------------------
		_widgets: []
		_uglyWorkarounds: undefined

		#----------------------------------------------
		# Public methods
		#----------------------------------------------
		initialize: (options) ->
			@_uglyWorkarounds = options.uglyWorkarounds
			super

		addSubscriptions: ->
			EventBus.subscribe EventKeys.TOGGLE_NAV_MENU, @_onNavMenuToggled
			super

		removeSubscriptions: ->
			EventBus.unsubcribe EventKeys.TOGGLE_NAV_MENU, @_onNavMenuToggled
			super

		renderStaticContent: ->
			@$el.html navTemplate()

			widgetContainer =
				navPanel: $ '.navigation-menu', @el

			_.each _.keys(widgetContainer), (key) =>
				@_widgets.push(require('view/widget/WidgetRenderer').renderWidgetsToContainer(widgetContainer[key], key, @_uglyWorkarounds))

		renderDynamicContent: ->
			super

		dispose: ->
			document.body.removeEventListener 'click', @_collapse, true
			super


		_onNavMenuToggled: =>
			do @_expand

		_expand: ->
			@$el.addClass CLASS_EXPANDED
			document.body.addEventListener 'click', @_collapse, true

		_collapse: =>
			@$el.removeClass CLASS_EXPANDED
			document.body.removeEventListener 'click', @_collapse, true


		CLASS_EXPANDED = 'navigation-menu-view--expanded'

		@NAME = 'NavigationView'

	return NavigationView