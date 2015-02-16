define (require) ->

	$ = require 'jquery'
	_ = require 'lib/underscore'
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
			super

		removeSubscriptions: ->
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
			super


		NAME: 'NavigationView'

	return NavigationView