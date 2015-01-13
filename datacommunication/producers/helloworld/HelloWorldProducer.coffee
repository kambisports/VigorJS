define (require) ->

	Q = require 'lib/q'
	Producer = require 'datacommunication/producers/Producer'

	QueryKeys = require 'datacommunication/QueryKeys'
	SubscriptionKeys = require 'datacommunication/SubscriptionKeys'

	# Collections needed to build/produce data
	HelloWorldRepository = require 'datacommunication/repositories/helloworld/HelloWorldRepository'

	class HelloWorldProducer extends Producer

		constructor: ->
			super
			HelloWorldRepository.on 'change', @onChangeInRepository, @

		dispose: ->
			HelloWorldRepository.off 'change', @onChangeInRepository, @
			HelloWorldRepository.notInterestedInUpdates @NAME
			super

		subscribe: (subscriptionKey, options) ->
			HelloWorldRepository.interestedInUpdates @NAME

		query: (queryKey, options) ->
			deferred = Q.defer()
			switch queryKey
				when QueryKeys.HELLO_WORLD_COUNT
					HelloWorldRepository.queryHelloWorldCount(options).then (data) =>
						deferred.resolve @buildData(data)
					return deferred.promise
				else
					throw new Error("Unknown query queryKey: #{queryKey}")

		# Handlers
		onChangeInRepository: (helloWorldModel) =>
			@produce SubscriptionKeys.NEW_HELLO_WORLD_COUNT, [helloWorldModel], ->

		buildData: (data) ->
			# Do some fancy data formatting here if needed
			return data

		SUBSCRIPTION_KEYS: [SubscriptionKeys.NEW_HELLO_WORLD_COUNT]
		QUERY_KEYS: [QueryKeys.HELLO_WORLD_COUNT]

		NAME: 'HelloWorldProducer'

