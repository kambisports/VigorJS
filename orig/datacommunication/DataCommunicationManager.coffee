define (require) ->

	# Required Imports
	#----------------------------------------------------------------------------------------------------------------
	_ = require 'lib/underscore'
	Hashtable = require 'lib/hashtable-require'
	ProducerManager = require 'datacommunication/producers/ProducerManager'
	ComponentIdentifier = require 'datacommunication/ComponentIdentifier'

	# Privately scoped variables
	#----------------------------------------------------------------------------------------------------------------
	subscriptionsWithComponentIdentifiers = new Hashtable()
	subscriptionsWithProducers = new Hashtable()
	producerManager = new ProducerManager()
	#----------------------------------------------------------------------------------------------------------------



	# Public interface definition
	#----------------------------------------------------------------------------------------------------------------
	DataCommunicationManager =

		subscribe: (componentId, subscriptionKey, subscriptionCb, subscriptionOptions = {}) ->

			componentIdentifier = new ComponentIdentifier(componentId, subscriptionCb, subscriptionOptions)

			if not subscriptionsWithComponentIdentifiers.containsKey(subscriptionKey)
				_createSubscription subscriptionKey

			# we have the subscription key already, add component id to list of components for that subscription
			_addComponentToSubscription subscriptionKey, componentIdentifier

			producerManager.subscribe subscriptionKey, subscriptionOptions


		unsubscribe: (componentId, subscriptionKey) ->
			# remove component for subscription key, if all components have been removed, remove subscription as well
			_removeComponentFromSubscription subscriptionKey, componentId


		unsubscribeAll: (componentId) ->
			# clear all subscriptions for given component
			keys = subscriptionsWithComponentIdentifiers.keys()
			len = keys.length

			while len--
				_removeComponentFromSubscription keys[len], componentId

		getSubscriptionsWithComponentId: (componentId) ->
			return subscriptionsWithComponentIdentifiers.get componentId

		reset: ->
			subscriptionsWithComponentIdentifiers = new Hashtable()
			subscriptionsWithProducers = new Hashtable()



	# Privately scoped functions
	#----------------------------------------------------------------------------------------------------------------
	_createSubscription = (subscriptionKey) ->

		subscriptionsWithComponentIdentifiers.put subscriptionKey, []

		producer = producerManager.getProducer subscriptionKey
		subscriptionsWithProducers.put subscriptionKey, producer


	_removeSubscription = (subscriptionKey) ->
		subscriptionsWithComponentIdentifiers.remove subscriptionKey
		subscriptionsWithProducers.remove subscriptionKey

		producerManager.removeProducer subscriptionKey


	_addComponentToSubscription = (subscriptionKey, componentIdentifier) ->
		subscriptionComponents = subscriptionsWithComponentIdentifiers.get subscriptionKey

		existingComponent = _.find subscriptionComponents, (component) ->
			component.id is componentIdentifier.id

		unless existingComponent
			subscriptionComponents.push componentIdentifier
			producerManager.addComponentToProducer subscriptionKey, componentIdentifier


	_removeComponentFromSubscription = (subscriptionKey, componentId) ->
		components = subscriptionsWithComponentIdentifiers.get subscriptionKey

		componentIndex = -1
		for component, index in components
			if component.id is componentId then componentIndex = index

		if componentIndex > -1 then components.splice componentIndex, 1

		# if subscription no long contains any components -> remove the subscription as well
		unless _isSubscriptionValid(subscriptionKey) then _removeSubscription(subscriptionKey)


	# Key is present in map and contains array of at least one component mapped for subscription
	_isSubscriptionValid = (subscriptionKey) ->
		componentIdentifiers = subscriptionsWithComponentIdentifiers.get subscriptionKey
		if _.isEmpty(componentIdentifiers) then false else true

	return DataCommunicationManager