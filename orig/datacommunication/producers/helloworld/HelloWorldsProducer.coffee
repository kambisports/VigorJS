define (require) ->

	Producer = require 'datacommunication/producers/Producer'
	SubscriptionKeys = require 'datacommunication/SubscriptionKeys'

	# Collections needed to build/produce data
	HelloWorldRepository = require 'datacommunication/repositories/helloworld/HelloWorldRepository'

	class HelloWorldsProducer extends Producer

		constructor: ->
			super
			HelloWorldRepository.on HelloWorldRepository.REPOSITORY_DIFF, @_onDiffInRepository, @

		dispose: ->
			HelloWorldRepository.off HelloWorldRepository.REPOSITORY_DIFF, @_onDiffInRepository, @
			super

		subscribe: (subscriptionKey, options) ->
			do HelloWorldRepository.fetchHelloWorlds
			do @_produceData

		_produceData: ->
			@produce SubscriptionKeys.HELLO_WORLDS, @_buildData()

		_buildData: ->
			models = HelloWorldRepository.getHelloWorlds()
			unless models.length > 0 then return
			models = _.without models, undefined
			models = @modelsToJSON models
			return models

		# Handlers
		_onDiffInRepository: (dataDiff) =>
			# the incomming data diff should be used to decide if we should produce or not
			# something was added or removed in repo, regenerate full list of hello world models
			if dataDiff.added.length > 0 or dataDiff.removed.length > 0
				do @_produceData

		SUBSCRIPTION_KEYS: [SubscriptionKeys.HELLO_WORLDS]
		NAME: 'HelloWorldsProducer'

