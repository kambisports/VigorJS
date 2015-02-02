define (require) ->

	Producer = require 'datacommunication/producers/Producer'

	SubscriptionKeys = require 'datacommunication/SubscriptionKeys'

	# Collections needed to build/produce data
	HelloWorldRepository = require 'datacommunication/repositories/helloworld/HelloWorldRepository'

	class HelloWorldProducer extends Producer

		constructor: ->
			super
			HelloWorldRepository.on HelloWorldRepository.REPOSITORY_DIFF, @_onDiffInRepository, @

		dispose: ->
			HelloWorldRepository.off HelloWorldRepository.REPOSITORY_DIFF, @_onDiffInRepository, @
			HelloWorldRepository.notInterestedInUpdates @NAME
			super

		subscribe: (subscriptionKey, options) ->
			HelloWorldRepository.interestedInUpdates @NAME
			switch subscriptionKey
				when SubscriptionKeys.HELLO_WORLDS
					do @_produceHelloWorlds

				when SubscriptionKeys.HELLO_WORLD_BY_ID
					model = HelloWorldRepository.queryById options.id
					@_produceData subscriptionKey, [model]
				else
					throw new Error("Unknown query subscriptionKey: #{key}")

		_produceHelloWorlds: ->
			models = HelloWorldRepository.queryHelloWorlds()
			@_produceData SubscriptionKeys.HELLO_WORLDS, models

		_produceData: (subscriptionKey, models = []) ->
			unless models.length > 0 then return

			models = _.without models, undefined
			models = _.map models, (model) ->
				return model.toJSON()

			switch subscriptionKey
				when SubscriptionKeys.HELLO_WORLDS
					@produce subscriptionKey, models, ->

				when SubscriptionKeys.HELLO_WORLD_BY_ID
					for model in models
						@produce subscriptionKey, model, (componentOptions) ->
							model.id is componentOptions.id
				else
					throw new Error("Unknown query subscriptionKey: #{key}")

		# Handlers
		_onDiffInRepository: (dataDiff) =>
			# the incomming data diff should be used to decide if we should produce or not
			# something was added or removed in repo, regenerate full list of hello world models
			if dataDiff.added.length > 0 or dataDiff.removed.length > 0 then do @_produceHelloWorlds

			# someting(s) was changed
			if dataDiff.changed.length > 0 then @_produceData SubscriptionKeys.HELLO_WORLD_BY_ID, dataDiff.changed

		SUBSCRIPTION_KEYS: [
			SubscriptionKeys.HELLO_WORLDS
			SubscriptionKeys.HELLO_WORLD_BY_ID
		]

		NAME: 'HelloWorldProducer'

