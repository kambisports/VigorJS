define (require) ->

	ServiceRepository = require 'datacommunication/repositories/ServiceRepository'

	HelloWorldService = require 'datacommunication/apiservices/HelloWorldService'

	class HelloWorldRepository extends ServiceRepository

		initialize: ->
			HelloWorldService.on HelloWorldService.HELLO_WORLDS_RECEIVED, @_helloWorldsReceived
			super

		fetchHelloWorlds: ->
			@callApiService HelloWorldService.NAME, {}
			return @getHelloWorlds()

		fetchById: (id) ->
			@callApiService HelloWorldService.NAME, { id: id }
			return @get id

		getHelloWorlds: ->
			return @models

		_helloWorldsReceived: (models) =>
			@set models

		makeTestInstance: () ->
			new HelloWorldRepository()

	return new HelloWorldRepository()