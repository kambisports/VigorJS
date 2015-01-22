define (require) ->

	Backbone = require 'lib/backbone'
	ViewModel = require 'common/ViewModel'
	QueryKeys = require 'datacommunication/QueryKeys'
	SubscriptionKeys = require 'datacommunication/SubscriptionKeys'

	class HelloWorldModel extends ViewModel

		id: 'HelloWorldModel'
		helloWorld: undefined

		constructor: ->
			super
			@helloWorld = new Backbone.Model()
			@queryAndSubscribe(QueryKeys.HELLO_WORLD_COUNT,
				{},
				SubscriptionKeys.NEW_HELLO_WORLD_COUNT,
				@_onNewHelloWorldData,
				{}
			).then @_storeData

		#----------------------------------------------
		# Private methods
		#----------------------------------------------
		_storeData: (data) =>
			@helloWorld.set data[0].toJSON()

		#----------------------------------------------
		# Callbacks
		#----------------------------------------------
		_onNewHelloWorldData: (data) =>
			@_storeData data

	return HelloWorldModel