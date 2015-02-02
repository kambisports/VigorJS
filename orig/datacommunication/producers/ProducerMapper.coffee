define (require) ->

	MostPopularProducer = require 'datacommunication/producers/mostpopular/MostPopularProducer'
	EventProducer = require 'datacommunication/producers/event/EventProducer'
	BetofferProducer = require 'datacommunication/producers/betoffer/BetofferProducer'
	HelloWorldProducer = require 'datacommunication/producers/helloworld/HelloWorldProducer'
	NavigationProducer = require 'datacommunication/producers/navigation/NavigationProducer'

	class ProducerMapper

		#
		producers: [
			MostPopularProducer
			EventProducer
			BetofferProducer
			HelloWorldProducer
			NavigationProducer
		]

		subscriptionKeyToProducerMap: {}

		constructor: ->

			@producers.forEach (producer) =>
				producer.prototype.SUBSCRIPTION_KEYS.forEach (subscriptionKey) =>
					@subscriptionKeyToProducerMap[subscriptionKey] = producer

		findProducerClassForSubscription: (subscriptionKey) ->
			producerClass = @subscriptionKeyToProducerMap[subscriptionKey]

			throw "No producer found for subscription #{subscriptionKey}!" unless producerClass
			producerClass
