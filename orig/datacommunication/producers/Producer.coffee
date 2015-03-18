define (require) ->

	_ = require 'lib/underscore'

	class Producer

		_isSubscribedToRepositories: undefined
		subscriptionKeyToComponents: undefined

		constructor: ->
			@subscriptionKeyToComponents = {}
			
			# add valid subscription keys to map (keys listed in subclass)
			for key in @SUBSCRIPTION_KEYS
				@subscriptionKeyToComponents[key] = {}

			_isSubscribedToRepositories = false

		getInstance: ->
			unless @instance?
				@instance = new @constructor()
			@instance


		dispose: ->


		addComponent: (subscriptionKey, subscription) ->
			registeredComponents = @subscriptionKeyToComponents[subscriptionKey]

			unless registeredComponents
				throw "Unknown subscription key: #{subscriptionKey}, could not add component!"

			existingSubscription = registeredComponents[subscription.id]
			if existingSubscription?
				throw "Component #{subscription.id} is already subscribed to the key #{subscriptionKey}"

			registeredComponents[subscription.id] = subscription
			@subscribe subscriptionKey, subscription.options

			unless @_isSubscribedToRepositories
				@subscribeToRepositories()
				@_isSubscribedToRepositories = true


		removeComponent: (subscriptionKey, componentId) ->
			# handle call with only componentId; remove component for all keys
			unless componentId?
				componentId = subscriptionKey
				_.each @SUBSCRIPTION_KEYS, (subscriptionKey) ->
					@removeComponent subscriptionKey, componentId
				, @
				return

			registeredComponents = @subscriptionKeyToComponents[subscriptionKey]

			subscription = registeredComponents[componentId]

			if subscription?
				@unsubscribe subscriptionKey, subscription.options
				delete registeredComponents[subscription.id]

				if @shouldUnsubscribeFromRepositories()
					@unsubscribeFromRepositories()
					@_isSubscribedToRepositories = false

		produce: (subscriptionKey, data, filterFn = ->) ->
			componentsForSubscription = @subscriptionKeyToComponents[subscriptionKey]

			componentsInterestedInChange = _.filter componentsForSubscription, (subscription) ->
				(_.isEmpty subscription.options) or (filterFn subscription.options)

			(component.callback data) for component in componentsInterestedInChange


		subscribe: (subscriptionKey, options) ->
			throw new Error("Subscription handler should be overriden in subclass! Implement for subscription #{subscriptionKey} with options #{options}")


		unsubscribe: (subscriptionKey, options) ->


		subscribeToRepositories: ->
			throw 'subscribeToRepositories should be overridden in subclass!'


		unsubscribeFromRepositories: ->
			throw 'unsubscribeFromRepositories should be overridden in subclass!'


		shouldUnsubscribeFromRepositories: ->
			# for..in finds out whether there are any keys
			# faster than checking whether the length of the keys is 0
			for key, components of @subscriptionKeyToComponents
				for component of components
					return false

			true


		extend: (obj, mixin) ->
			obj[name] = method for name, method of mixin
			obj


		mixin: (instance, mixin) ->
			@extend instance, mixin


		decorate: (data, decoratorList) ->
			for decorator in decoratorList
				decorator(data)
			return data


		modelToJSON: (model) ->
			model.toJSON()


		modelsToJSON: (models) ->
			_.map models, @modelToJSON


		# Default
		SUBSCRIPTION_KEYS: []
