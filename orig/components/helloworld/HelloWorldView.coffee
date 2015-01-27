define (require) ->

	$ = require 'jquery'
	ComponentView = require 'common/ComponentView'
	tmpl = require 'hbs!./templates/HelloWorld'

	# Items generated in this class are of this type
	HelloWorldItemViewModel = require './HelloWorldItemViewModel'
	HelloWorldItemView = require './HelloWorldItemView'

	class HelloWorldView extends ComponentView

		tagName: 'div'
		className: 'modularized__hello-world'

		#--------------------------------------
		#	Private properties
		#--------------------------------------

		# DOM references
		$helloWorldItemsList: undefined

		# References to all items in this view
		_helloWorldItems: []

		#----------------------------------------------
		# Public methods
		#----------------------------------------------

		initialize: (options) ->
			super
			@listenTo @viewModel.helloWorldItems, 'add', @_onHelloWorldItemsAdd
			@listenTo @viewModel.helloWorldItems, 'remove', @_onHelloWorldItemsRemove

		dispose: ->
			@stopListening @viewModel.helloWorldItems, 'add', @_onHelloWorldItemsAdd
			@stopListening @viewModel.helloWorldItems, 'remove', @_onHelloWorldItemsRemove

		renderStaticContent: ->
			@$el.html tmpl {}

			@$helloWorldItemsList = @$ '.modularized__hello-world-items-list'

			return @

		renderDynamicContent: ->
			_.each @_helloWorldItems, (helloWorldItemView) ->
				@$helloWorldItemsList.append helloWorldItemView.render().el
			, @

			return @

		addSubscriptions: ->
			do @viewModel.addSubscriptions

		# Override this.
		# Remove view model subscriptions.
		removeSubscriptions: ->
			do @viewModel.removeSubscriptions

		#----------------------------------------------
		# Private methods
		#----------------------------------------------
		_onHelloWorldItemsAdd: (addedItem, collection, options) ->
			helloWorldItemModel = new HelloWorldItemViewModel addedItem.id
			helloWorldItemView = new HelloWorldItemView
				viewModel: helloWorldItemModel

			@_helloWorldItems.push helloWorldItemView

			do @renderDynamicContent

		_onHelloWorldItemsRemove: (removedItem, collection, options) ->
			removedComponent = @_helloWorldItems.splice(options.index, 1)[0]

			if removedComponent
				do removedComponent.el.remove
				do removedComponent.dispose

	return HelloWorldView