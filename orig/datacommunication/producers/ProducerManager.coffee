define (require) ->

	ProducerMapper = require 'datacommunication/producers/ProducerMapper'

	class ProducerManager

		constructor: ->
			@producerMapper = new ProducerMapper()


		registerProducers: (producers) ->
			producers.forEach (producer) =>
				@producerMapper.register producer


		producerForKey: (subscriptionKey) ->
			producer = @producerMapper.producerForKey subscriptionKey


		subscribeComponentToKey: (subscriptionKey, subscription) ->
			producer = @producerForKey subscriptionKey
			producer.addComponent subscriptionKey, subscription


		unsubscribeComponentFromKey: (subscriptionKey, componentId) ->
			producer = @producerForKey subscriptionKey
			producer.removeComponent subscriptionKey, componentId


		unsubscribeComponent: (componentId) ->
			@producerMapper.producers.forEach (producer) ->
				producer.removeComponent componentId


	new ProducerManager()
