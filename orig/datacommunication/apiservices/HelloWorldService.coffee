define (require) ->

	ApiService = require 'datacommunication/apiservices/ApiService'

	# this resource defines if this service should poll / fetch data
	HelloWorldRepository = require 'datacommunication/repositories/helloworld/HelloWorldRepository'

	class HelloWorldService extends ApiService

		count: 0

		constructor: (helloWorldRepository) ->
			super helloWorldRepository, 5000

			# simulated incomming from another service
			setTimeout =>
				response = [
					{
						'id': 'dummy'
						'message': 'im a change'
						'count': 100
					},
					{
						'id': 'rummy'
						'message': 'im added'
						'count': 5
					},
					{
						'id': 'summy'
						'message': 'im also added'
						'count': 3
					}
				]

				@parse response
			, 10000

		parse: (response) ->
			super response
			if Array.isArray(response)
				@repository.set response
			else
				@repository.set @_buildHelloWorldModels(response)

		# Update the collection related to his service
		_buildHelloWorldModels: (response) ->
			@count++
			models = [{
					'id': 'dummy'
					'message': response.message
					'count': @count
				},
				{
					'id': 'tummy'
					'message': 'im going to be removed'
					'count': 0
				}
			]

			return models


		# Unit testing of singleton
		makeTestInstance: (defaultCollection = HelloWorldRepository) ->
			new HelloWorldService defaultCollection

		NAME: 'HelloWorldService'

	return new HelloWorldService HelloWorldRepository


