define (require) ->

	ProducerMapper = require 'datacommunication/producers/ProducerMapper'

	class ProducerManager

		producerMapper: new ProducerMapper()

		# key: ProducerClass.NAME, value: instance of ProducerClass
		instansiatedProducers: {}

		getProducer: (subscriptionKey) ->
			producerClass = @producerMapper.findProducerClassForSubscription subscriptionKey
			@_instansiateProducer producerClass

		removeProducer: (subscriptionKey) ->
			producerClass = @producerMapper.findProducerClassForSubscription subscriptionKey

			producer = @instansiatedProducers[producerClass.prototype.NAME]
			if producer
				do producer.dispose
				delete @instansiatedProducers[producerClass.prototype.NAME]

		addComponentToProducer: (subscriptionKey, componentIdentifier) ->
			producer = @getProducer subscriptionKey

			# add sub key so producer know what components to call produce for!
			producer.addComponent subscriptionKey, componentIdentifier

		###
		query: (queryKey, options) ->
			producerClass = @producerMapper.findProducerClassForQuery queryKey
			producer = @_instansiateProducer producerClass
			# returns a Q promise
			producer.query queryKey, options
		###

		subscribe: (subscriptionKey, options) ->
			producerClass = @producerMapper.findProducerClassForSubscription subscriptionKey
			producer = @_instansiateProducer producerClass

			# synchronous call
			producer.subscribe subscriptionKey, options

		_instansiateProducer: (producerClass) ->
			if not @instansiatedProducers[producerClass.prototype.NAME]
				producer = new producerClass()
				@instansiatedProducers[producerClass.prototype.NAME] = producer

			@instansiatedProducers[producerClass.prototype.NAME]

	return ProducerManager