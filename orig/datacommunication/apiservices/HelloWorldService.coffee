define (require) ->

	ApiService = require 'datacommunication/apiservices/ApiService'

	# this resource defines if this service should poll / fetch data

	class HelloWorldService extends ApiService

		count: 0

		constructor: ->
			super 3000

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
			, 12500


		run: (options) ->
			console.log 'helloWorldOptons: ', options
			do @startPolling

		parse: (response) ->
			super response
			models = []

			if Array.isArray(response)
				models = response
			else
				models = @_buildHelloWorldModels(response)

			@propagateResponse @HELLO_WORLDS_RECEIVED, models


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


		HELLO_WORLDS_RECEIVED: 'hello-worlds-received'

		NAME: 'HelloWorldService'

	return new HelloWorldService()


