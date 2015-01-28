class ProducerMapper

	producers: []
	subscriptionKeyToProducerMap: {}

	constructor: ->
		@producers.forEach (producer) =>
			producer.prototype.SUBSCRIPTION_KEYS.forEach (subscriptionKey) =>
				@subscriptionKeyToProducerMap[subscriptionKey] = producer

	findProducerClassForSubscription: (subscriptionKey) ->
		producerClass = @subscriptionKeyToProducerMap[subscriptionKey]

		throw "No producer found for subscription #{subscriptionKey}!" unless producerClass
		producerClass

Vigor.ProducerMapper = ProducerMapper