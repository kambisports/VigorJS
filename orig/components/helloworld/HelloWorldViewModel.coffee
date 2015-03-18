define (require) ->

	Backbone = require 'lib/backbone'
	ViewModel = require 'common/ViewModel'
	SubscriptionKeys = require 'datacommunication/SubscriptionKeys'

	class HelloWorldModel extends ViewModel

		id: 'HelloWorldModel'
		helloWorldItems: undefined

		constructor: () ->
			super
			@helloWorldItems = new Backbone.Collection()

		addSubscriptions: ->
			@subscribe SubscriptionKeys.HELLO_WORLDS, @_onHelloWorldItemsChanged, {}

		removeSubscriptions: ->
			@unsubscribe SubscriptionKeys.HELLO_WORLDS

		#----------------------------------------------
		# Callbacks
		#----------------------------------------------
		_onHelloWorldItemsChanged: (jsonArray) =>
			@helloWorldItems.set jsonArray, {add: true, remove: true, merge: false}

	return HelloWorldModel