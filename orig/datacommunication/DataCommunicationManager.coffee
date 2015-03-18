define (require) ->

	# Required Imports
	#----------------------------------------------------------------------------------------------------------------
	_ = require 'lib/underscore'
	Subscription = require 'datacommunication/ComponentIdentifier'
	producerManager = require 'datacommunication/producers/ProducerManager'


	# Public interface definition
	#----------------------------------------------------------------------------------------------------------------
	DataCommunicationManager =

		registerProducers: (producers) ->
			producerManager.registerProducers producers


		subscribe: (componentId, subscriptionKey, callback, subscriptionOptions = {}) ->
			subscription = new Subscription componentId, callback, subscriptionOptions
			producerManager.subscribeComponentToKey subscriptionKey, subscription


		unsubscribe: (componentId, subscriptionKey) ->
			producerManager.unsubscribeComponentFromKey subscriptionKey, componentId


		unsubscribeAll: (componentId) ->
			producerManager.unsubscribeComponent componentId


	return DataCommunicationManager
