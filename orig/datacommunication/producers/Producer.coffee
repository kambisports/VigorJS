define (require) ->

	_ = require 'lib/underscore'

	class Producer

		subscriptionKeyToComponents: {}

		pushSubscriptionId: undefined

		constructor: ->
			@pushSubscriptionId = _.uniqueId()

			#@createPushSubscription 'PUSH_TYPE_SPECIFIC_EVENTS'
			#@updatePushSubscription [1,2,3,4,5]
			#@removePushSubscription()

			# add valid subscription keys to map (keys listed in subclass)
			for key in @SUBSCRIPTION_KEYS
				@subscriptionKeyToComponents[key] = []

		dispose: ->

		addComponent: (subscriptionKey, componentIdentifier) ->
			registeredComponents = @subscriptionKeyToComponents[subscriptionKey]
			unless registeredComponents then throw new Error("Unknown subscription key: #{subscriptionKey}, could not add component!")

			@subscriptionKeyToComponents[subscriptionKey].push componentIdentifier

		produce: (subscriptionKey, data, filterFn = ->) ->
			componentsForSubscription = @subscriptionKeyToComponents[subscriptionKey]
			componentsInterestedInChange = _.filter componentsForSubscription, (componentIdentifier) ->
				_.isEmpty(componentIdentifier.options) or filterFn(componentIdentifier.options)

			component.callback(data) for component in componentsInterestedInChange

		subscribe: (subscriptionKey, options) ->
			throw new Error("Subscription handler should be overriden in subclass! Implement for subscription #{subscriptionKey} with options #{options}")

		extend: (obj, mixin) ->
			obj[name] = method for name, method of mixin
			obj

		mixin: (instance, mixin) ->
			@extend instance, mixin

		decorate: (data, decoratorList) ->
			for decorator in decoratorList
				decorator(data)
			return data

		createPushSubscription: (type) ->
			console.log 'C_PUSH_SUBSCRIPTION_CREATE', type, @pushSubscriptionId

		updatePushSubscription: (data) ->
			console.log 'C_PUSH_SUBSCRIPTION_UPDATE', data, @pushSubscriptionId

		removePushSubscription: () ->
			console.log 'C_PUSH_SUBSCRIPTION_REMOVE', null, @pushSubscriptionId

		modelsToJSON: (models) ->
			modelsJSON = _.map models, (model) ->
				return model.toJSON()
			return modelsJSON

		# Default
		SUBSCRIPTION_KEYS: []
		NAME: 'Producer'