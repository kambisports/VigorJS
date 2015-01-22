define (require) ->

	Backbone = require 'lib/backbone'
	ViewModel = require 'common/ViewModel'
	SubscriptionKeys = require 'datacommunication/SubscriptionKeys'

	class HelloWorldModel extends ViewModel

		id: 'HelloWorldModel'
		helloWorldId: undefined
		helloWorld: undefined

		constructor: (@helloWorldId) ->
			super
			@helloWorld = new Backbone.Collection()

		addSubscriptions: ->
			@subscribe SubscriptionKeys.HELLO_WORLD_BY_ID, @_onChangedById, { id: @helloWorldId }
			@subscribe SubscriptionKeys.HELLO_WORLD_ADDED, @_onAdded
			@subscribe SubscriptionKeys.HELLO_WORLD_REMOVED, @_onRemoved

		removeSubscriptions: ->
			@unsubscribe SubscriptionKeys.HELLO_WORLD_BY_ID
			@unsubscribe SubscriptionKeys.HELLO_WORLD_ADDED
			@unsubscribe SubscriptionKeys.HELLO_WORLD_REMOVED

		#----------------------------------------------
		# Private methods
		#----------------------------------------------

		#----------------------------------------------
		# Callbacks
		#----------------------------------------------
		_onAdded: (jsonArray) =>
			console.log 'HelloWorldViewModel:_onAdded before', @helloWorld.models
			@helloWorld.add jsonArray
			console.log 'HelloWorldViewModel:_onAdded after', @helloWorld.models

		_onRemoved: (jsonArray) =>
			console.log 'HelloWorldViewModel:_onRemoved before', @helloWorld.models
			@helloWorld.remove jsonArray
			console.log 'HelloWorldViewModel:_onRemoved after', @helloWorld.models

		_onChangedById: (jsonData) =>
			console.log 'HelloWorldViewModel:_onChangedById'
			@helloWorld.set jsonData, {add: false, remove: false, merge: true}

	return HelloWorldModel