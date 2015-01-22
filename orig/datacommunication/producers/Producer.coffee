define (require) ->

	Q = require 'lib/q'
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
			unless registeredComponents then throw new Error('Unknown subscription key, could not add component!')

			@subscriptionKeyToComponents[subscriptionKey].push componentIdentifier

		produce: (subscriptionKey, data, filterFn) ->
			componentsForSubscription = @subscriptionKeyToComponents[subscriptionKey]
			componentsInterestedInChange = _.filter componentsForSubscription, (componentIdentifier) ->
				_.isEmpty(componentIdentifier.options) or filterFn(componentIdentifier.options)

			component.callback(data) for component in componentsInterestedInChange

		# Implement in subclass
		###
		query: (queryKey, options) ->
			deferred = Q.defer()
			deferred.reject new Error("Query handler should be overriden in subclass! Implement for query #{queryKey} with options #{options}")

			return deferred.promise
		###

		subscribe: (subscriptionKey, options) ->
			throw new Error("Subscription handler should be overriden in subclass! Implement for subscription #{subscriptionKey} with options #{options}")

		createPushSubscription: (type) ->
			console.log 'C_PUSH_SUBSCRIPTION_CREATE', type, @pushSubscriptionId

		updatePushSubscription: (data) ->
			console.log 'C_PUSH_SUBSCRIPTION_UPDATE', data, @pushSubscriptionId

		removePushSubscription: () ->
			console.log 'C_PUSH_SUBSCRIPTION_REMOVE', null, @pushSubscriptionId

		# Default
		SUBSCRIPTION_KEYS : []

		#QUERY_KEYS: []

		NAME : 'Producer'
