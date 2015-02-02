class Producer

	subscriptionKeyToComponents: {}

	constructor: ->
		do @_addKeysToMap

	addComponent: (subscriptionKey, componentIdentifier) ->
		registeredComponents = @subscriptionKeyToComponents[subscriptionKey]
		unless registeredComponents
			throw new Error('Unknown subscription key, could not add component!')

		@subscriptionKeyToComponents[subscriptionKey].push componentIdentifier

	produce: (subscriptionKey, data, filterFn) ->
		componentsForSubscription = @subscriptionKeyToComponents[subscriptionKey]
		componentsInterestedInChange = _.filter componentsForSubscription, (componentIdentifier) ->
			_.isEmpty(componentIdentifier.options) or filterFn(componentIdentifier.options)

		component.callback(data) for component in componentsInterestedInChange

	subscribe: (subscriptionKey, options) ->
		throw new Error("Subscription handler should be overriden in subclass! Implement for subscription #{subscriptionKey} with options #{options}")

	dispose: ->
		throw new Error("Dispose shuld be overriden in subclass!")

	@extend = Backbone.View.extend

	# add valid subscription keys to map (keys listed in subclass)
	_addKeysToMap: ->
		for key in @SUBSCRIPTION_KEYS
			@subscriptionKeyToComponents[key] = []

	# Default
	SUBSCRIPTION_KEYS: []
	NAME: 'Producer'

Vigor.Producer = Producer