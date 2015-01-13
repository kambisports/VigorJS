define (require) ->

	ApiService = require 'datacommunication/apiservices/ApiService'

	# this resource defines if this service should poll / fetch data
	HelloWorldRepository = require 'datacommunication/repositories/helloworld/HelloWorldRepository'

	class HelloWorldService extends ApiService

		count: 0

		constructor: (helloWorldRepository) ->
			super helloWorldRepository, 1000

		parse: (response) ->
			super response

			@_buildHelloWorldModels response

		# Update the collection related to his service
		_buildHelloWorldModels: (response) ->
			@count++
			@repository.set
				'id': 'dummy'
				'message': response.message
				'count': @count


		# Unit testing of singleton
		makeTestInstance: (defaultCollection = HelloWorldRepository) ->
			new HelloWorldService defaultCollection

		NAME: 'HelloWorldService'

	return new HelloWorldService HelloWorldRepository


