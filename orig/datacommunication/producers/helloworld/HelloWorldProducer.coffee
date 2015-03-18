define (require) ->

	Producer = require 'datacommunication/producers/Producer'
	SubscriptionKeys = require 'datacommunication/SubscriptionKeys'

	# Collections needed to build/produce data
	HelloWorldRepository = require 'datacommunication/repositories/helloworld/HelloWorldRepository'

	class HelloWorldProducer extends Producer

		subscribeToRepositories: ->
			HelloWorldRepository.on HelloWorldRepository.REPOSITORY_DIFF, @_onDiffInRepository, @

		unsubscribeFromRepositories: ->
			HelloWorldRepository.off HelloWorldRepository.REPOSITORY_DIFF, @_onDiffInRepository, @

		subscribe: (subscriptionKey, options) ->
			# If we want to send the id to the service and fetch something specific from the server
			# model = HelloWorldRepository.fetchById options.id

			# If we are only interested in already loaded models
			model = HelloWorldRepository.get options.id
			@_produceData [model]

		_produceData: (models = []) ->
			unless models.length > 0 then return

			models = _.without models, undefined
			models = @modelsToJSON models

			for model in models
				# model = @decorate model, [@decorator.addSomeFancyData]
				@produce SubscriptionKeys.HELLO_WORLD, model, (componentOptions) ->
					model.id is componentOptions.id

		_onDiffInRepository: (dataDiff) =>
			if dataDiff.changed.length > 0
				@_produceData dataDiff.changed

		SUBSCRIPTION_KEYS: [SubscriptionKeys.HELLO_WORLD]
