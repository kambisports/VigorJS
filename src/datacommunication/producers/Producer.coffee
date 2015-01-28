class Producer

	subscriptionKeyToComponents: {}

	constructor: ->
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

	subscribe: (subscriptionKey, options) ->
		throw new Error("Subscription handler should be overriden in subclass! Implement for subscription #{subscriptionKey} with options #{options}")

	# Default
	SUBSCRIPTION_KEYS: []
	NAME: 'Producer'

Vigor.Producer = Producer