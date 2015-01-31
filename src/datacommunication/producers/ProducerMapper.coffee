class ProducerMapper

	producers: []
	subscriptionKeyToProducerMap: {}

	constructor: ->
		do @_buildMap

	findProducerClassForSubscription: (subscriptionKey) ->
		producerClass = @subscriptionKeyToProducerMap[subscriptionKey]
		throw "There are no producers registered - register producers through the DataCommunicationManager" unless @producers.length > 0
		throw "No producer found for subscription #{subscriptionKey}!" unless producerClass
		return producerClass

	addProducerClass: (producerClass) ->
		if @producers.indexOf(producerClass) is -1
			@producers.push producerClass
			do @_buildMap
		return @

	removeProducerClass: (producerClass) ->
		index = @producers.indexOf(producerClass)
		if index isnt -1
			@producers.splice index, 1
			do @_buildMap
		return @

	_buildMap: ->
		@producers.forEach (producer) =>
			producer.prototype.SUBSCRIPTION_KEYS.forEach (subscriptionKey) =>
				@subscriptionKeyToProducerMap[subscriptionKey] = producer

Vigor.ProducerMapper = ProducerMapper