define (require) ->

	NO_PRODUCERS_ERROR = "There are no producers registered - register producers through the DataCommunicationManager"
	NO_PRODUCER_FOUND_ERROR = (subscriptionKey) ->
		"No producer found for subscription #{subscriptionKey}!"

	class ProducerMapper

		constructor: ->
			@producers = []
			@producersByKey = {}


		producerClassForKey: (subscriptionKey) ->
			if @producers.length is 0
				throw NO_PRODUCERS_ERROR

			producerClass = @producersByKey[subscriptionKey]

			unless producerClass
				throw NO_PRODUCER_FOUND_ERROR subscriptionKey
			
			producerClass


		producerForKey: (subscriptionKey) ->
			producerClass = @producerClassForKey subscriptionKey
			producerClass::getInstance()


		register: (producerClass) ->
			if (@producers.indexOf producerClass) is -1
				@producers.push producerClass
				
				for key in producerClass.prototype.SUBSCRIPTION_KEYS
					@producersByKey[key] = producerClass
