define (require) ->

	ServiceRepository = require 'datacommunication/repositories/ServiceRepository'

	HelloWorldService = require 'datacommunication/apiservices/HelloWorldService'

	class HelloWorldRepository extends ServiceRepository

		ALL: 'all'
		BY_ID: 'id'
		services:
			'all': HelloWorldService
			'id': HelloWorldService

		initialize: ->
			HelloWorldService.on HelloWorldService.HELLO_WORLDS_RECEIVED, @_helloWorldsReceived
			super

		getHelloWorlds: ->
			return @models

		_helloWorldsReceived: (models) =>
			@set models

	new HelloWorldRepository()
