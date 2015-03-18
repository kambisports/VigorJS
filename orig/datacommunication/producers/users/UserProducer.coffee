define (require) ->

	Producer = require 'datacommunication/producers/Producer'
	SubscriptionKeys = require 'datacommunication/SubscriptionKeys'

	# Collections needed to build/produce data
	UserRepository = require 'datacommunication/repositories/users/UsersRepository'

	class UserProducer extends Producer

		# the fetch subscription to the repository
		repoFetchSubscription: undefined

		subscribeToRepositories: ->
			@repoFetchSubscription =
				pollingInterval: 15000

			UserRepository.addSubscription UserRepository.BALANCE, @repoFetchSubscription
			UserRepository.on UserRepository.REPOSITORY_DIFF, @_onDiffInRepository, @

		unsubscribeFromRepositories: ->
			UserRepository.off UserRepository.REPOSITORY_DIFF, @_onDiffInRepository, @
			UserRepository.removeSubscription UserRepository.BALANCE, @repoFetchSubscription

		subscribe: ->
			model = UserRepository.getUser()
			@_produceData [model]

		_produceData: (models = []) ->
			unless models.length > 0 then return

			models = _.without models, undefined
			models = @modelsToJSON models

			for model in models
				@produce SubscriptionKeys.USER, model, (componentOptions) ->
					model.id is componentOptions.id

		_onDiffInRepository: (dataDiff) =>
			if dataDiff.changed.length > 0
				@_produceData dataDiff.changed

		SUBSCRIPTION_KEYS: [SubscriptionKeys.USER]
