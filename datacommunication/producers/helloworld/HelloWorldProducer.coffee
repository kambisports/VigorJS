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
			HelloWorldRepository.on HelloWorldRepository.REPOSITORY_DIFF, @_onDiffInRepository, @

		dispose: ->
			HelloWorldRepository.off HelloWorldRepository.REPOSITORY_DIFF, @_onDiffInRepository, @
			HelloWorldRepository.notInterestedInUpdates @NAME
			super

		subscribe: (subscriptionKey, options) ->
			HelloWorldRepository.interestedInUpdates @NAME
			switch subscriptionKey
				when SubscriptionKeys.HELLO_WORLD_ADDED
					models = HelloWorldRepository.queryHelloWorlds()
					@_produceData subscriptionKey, models
				# Removed items will not be present in repo
				when SubscriptionKeys.HELLO_WORLD_REMOVED
					return
				when SubscriptionKeys.HELLO_WORLD_BY_ID
					model = HelloWorldRepository.queryById options.id
					@_produceData subscriptionKey, [model]
				else
					throw new Error("Unknown query subscriptionKey: #{key}")

		_produceData: (subscriptionKey, models = []) ->
			unless models.length > 0 then return

			models = _.without models, undefined
			models = _.map models, (model) ->
				return model.toJSON()

			switch subscriptionKey
				when SubscriptionKeys.HELLO_WORLD_ADDED
					@produce subscriptionKey, models, ->

				when SubscriptionKeys.HELLO_WORLD_REMOVED
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
			#console.log '_onDiffInRepository', dataDiff
			if dataDiff.added.length > 0 then @_produceData SubscriptionKeys.HELLO_WORLD_ADDED, dataDiff.added
			if dataDiff.removed.length > 0 then @_produceData SubscriptionKeys.HELLO_WORLD_REMOVED, dataDiff.removed
			if dataDiff.changed.length > 0 then @_produceData SubscriptionKeys.HELLO_WORLD_BY_ID, dataDiff.changed


		SUBSCRIPTION_KEYS: [
			SubscriptionKeys.HELLO_WORLD_ADDED
			SubscriptionKeys.HELLO_WORLD_REMOVED
			SubscriptionKeys.HELLO_WORLD_BY_ID
		]

		NAME: 'HelloWorldProducer'

