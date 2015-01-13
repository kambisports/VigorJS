define (require) ->

	Q = require 'lib/q'
	ServiceRepository = require 'datacommunication/repositories/ServiceRepository'

	class HelloWorldRepository extends ServiceRepository

		queryHelloWorldCount: ->
			deferred = Q.defer()

			unless @isEmpty() then deferred.resolve @models

			@trigger ServiceRepository::POLL_ONCE

			@listenToOnce @, 'all', ->
				deferred.resolve @models

			return deferred.promise

		makeTestInstance: () ->
			new HelloWorldRepository()

	return new HelloWorldRepository()