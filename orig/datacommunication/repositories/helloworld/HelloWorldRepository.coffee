define (require) ->

	ServiceRepository = require 'datacommunication/repositories/ServiceRepository'

	class HelloWorldRepository extends ServiceRepository

		queryHelloWorlds: ->
			unless @isEmpty() then return @models
			return []

		queryById: (id) ->
			@get 'id': id

		makeTestInstance: () ->
			new HelloWorldRepository()

	return new HelloWorldRepository()