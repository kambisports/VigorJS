define (require) ->

	ComponentView = require 'common/ComponentView'
	tmpl = require 'hbs!./templates/HelloWorldItem'

	class HelloWorldItemView extends ComponentView

		tagName: 'li'
		className: 'modularized__hello-world-item'

		#----------------------------------------------
		# Public methods
		#----------------------------------------------

		initialize: (options) ->
			super
			@listenTo @viewModel.helloWorld, 'change', @_onHelloWorldItemChanged

		dispose: ->
			@stopListening @viewModel.helloWorld, 'change', @_onHelloWorldItemChanged
			super

		# and item is bootstrapped with a model
		renderStaticContent: ->
			@$el.html tmpl @viewModel.helloWorld.toJSON()
			return @

		renderDynamicContent: ->
			@$el.html tmpl @viewModel.helloWorld.toJSON()
			return @

		addSubscriptions: ->
			do @viewModel.addSubscriptions

		removeSubscriptions: ->
			do @viewModel.removeSubscriptions

		#----------------------------------------------
		# Private methods
		#----------------------------------------------

		_onHelloWorldItemChanged: ->
			do @renderDynamicContent


	return HelloWorldItemView