define (require) ->

	_ = require 'lib/underscore'
	Q = require 'lib/q'
	Hashtable = require 'lib/hashtable-require'

	ProducerManager = require 'datacommunication/producers/ProducerManager'
	ComponentIdentifier = require 'datacommunication/ComponentIdentifier'

	ApiServices = require 'datacommunication/apiservices'

	class DataCommunicationManager

		subscriptionsWithComponentIdentifiers: undefined
		subscriptionsWithProducers: undefined

		producerManager: undefined
		apiServices: undefined

		constructor: ->
			@subscriptionsWithComponentIdentifiers = new Hashtable()
			@subscriptionsWithProducers = new Hashtable()

			@producerManager = new ProducerManager()

			# Only used to create singletons of services in application
			@apiServices = new ApiServices()

		# Public methods
		subscribe: (componentId, subscriptionKey, subscriptionCb, subscriptionOptions = {}) ->
			componentIdentifier = new ComponentIdentifier(componentId, subscriptionCb, subscriptionOptions)

			if not @subscriptionsWithComponentIdentifiers.containsKey(subscriptionKey)
				@_createSubscription subscriptionKey

			# we have the subscription key already, add component id to list of components for that subscription
			@_addComponentToSubscription subscriptionKey, componentIdentifier

			@producerManager.subscribe subscriptionKey, subscriptionOptions


		unsubscribe: (componentId, subscriptionKey) ->
			# remove component for subscription key, if all components have been removed, remove subscription as well
			@_removeComponentFromSubscription subscriptionKey, componentId


		unsubscribeAll: (componentId) ->
			# clear all subscriptions for given component
			keys = @subscriptionsWithComponentIdentifiers.keys()
			len = keys.length

			while len--
				@_removeComponentFromSubscription keys[len], componentId

		###
		query: (key, options) ->
			@producerManager.query key, options
		###


		# Private methods
		_createSubscription: (subscriptionKey) ->
			@subscriptionsWithComponentIdentifiers.put subscriptionKey, []

			producer = @producerManager.getProducer subscriptionKey
			@subscriptionsWithProducers.put subscriptionKey, producer


		_removeSubscription: (subscriptionKey) ->
			@subscriptionsWithComponentIdentifiers.remove subscriptionKey
			@subscriptionsWithProducers.remove subscriptionKey

			@producerManager.removeProducer subscriptionKey


		_addComponentToSubscription: (subscriptionKey, componentIdentifier) ->
			subscriptionComponents = @subscriptionsWithComponentIdentifiers.get subscriptionKey

			existingComponent = _.find subscriptionComponents, (component) ->
				component.id is componentIdentifier.id

			unless existingComponent
				subscriptionComponents.push componentIdentifier
				@producerManager.addComponentToProducer subscriptionKey, componentIdentifier


		_removeComponentFromSubscription: (subscriptionKey, componentId) ->
			components = @subscriptionsWithComponentIdentifiers.get subscriptionKey

			componentIndex = -1
			for component, index in components
				if component.id is componentId then componentIndex = index

			if componentIndex > -1 then components.splice componentIndex, 1

			# if subscription no long contains any components -> remove the subscription as well
			unless @_isSubscriptionValid(subscriptionKey) then @_removeSubscription(subscriptionKey)


		# Key is present in map and contains array of at least one component mapped for subscription
		_isSubscriptionValid: (subscriptionKey) ->
			componentIdentifiers = @subscriptionsWithComponentIdentifiers.get subscriptionKey
			if _.isEmpty(componentIdentifiers) then false else true


		# Unit testing of singleton
		makeTestInstance: ->
			new DataCommunicationManager()

	return new DataCommunicationManager()

