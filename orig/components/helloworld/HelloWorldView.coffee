define (require) ->

	ComponentView = require 'common/ComponentView'
	tmpl = require 'hbs!./templates/HelloWorld'

	class HelloWorldView extends ComponentView

		tagName: 'div'
		className: 'modularized__hello-world'

		#--------------------------------------
		#	Private properties
		#--------------------------------------
		_viewModel: undefined

		#----------------------------------------------
		# Public methods
		#----------------------------------------------

		initialize: (options) ->
			@_viewModel = options.viewModel
			@listenTo @_viewModel.helloWorld, 'change', @_onHelloWorldChange
			super

		render: ->
			@$el.html tmpl(@_viewModel.helloWorld.toJSON())
			return @

		#----------------------------------------------
		# Private methods
		#----------------------------------------------
		_onHelloWorldChange: =>
			do @render

	return HelloWorldView