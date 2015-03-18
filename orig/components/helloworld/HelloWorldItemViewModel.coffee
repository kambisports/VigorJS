define (require) ->

	Backbone = require 'lib/backbone'
	ViewModel = require 'common/ViewModel'
	SubscriptionKeys = require 'datacommunication/SubscriptionKeys'

	class HelloWorldItemViewModel extends ViewModel

		id: 'HelloWorldItemModel'
		helloWorldId: undefined
		helloWorld: undefined

		constructor: (@helloWorldId) ->
			super
			@helloWorld = new Backbone.Model()

		addSubscriptions: ->
			@subscribe SubscriptionKeys.HELLO_WORLD, @_onChangedById, { id: @helloWorldId }

		removeSubscriptions: ->
			@unsubscribe SubscriptionKeys.HELLO_WORLD

		#----------------------------------------------
		# Callbacks
		#----------------------------------------------
		_onChangedById: (jsonData) =>
			@helloWorld.set jsonData, {add: false, remove: false, merge: true}

	return HelloWorldItemViewModel