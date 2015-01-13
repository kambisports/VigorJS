define (require) ->

	MostPopularProducer = require 'datacommunication/producers/mostpopular/MostPopularProducer'
	EventProducer = require 'datacommunication/producers/event/EventProducer'
	BetofferProducer = require 'datacommunication/producers/betoffer/BetofferProducer'
	HelloWorldProducer = require 'datacommunication/producers/helloworld/HelloWorldProducer'
	GroupsProducer = require 'datacommunication/producers/groups/GroupsProducer'
	NavigationProducer = require 'datacommunication/producers/navigation/NavigationProducer'

	class ProducerMapper

		#
		producers: [
			MostPopularProducer
			EventProducer
			BetofferProducer
			HelloWorldProducer
			GroupsProducer
			NavigationProducer
		]

		subscriptionKeyToProducerMap: {}
		queryKeyToProducerMap: {}

		constructor: ->

			@producers.forEach (producer) =>
				producer.prototype.SUBSCRIPTION_KEYS.forEach (subscriptionKey) =>
					@subscriptionKeyToProducerMap[subscriptionKey] = producer

				producer.prototype.QUERY_KEYS.forEach (queryKey) =>
					@queryKeyToProducerMap[queryKey] = producer

		findProducerClassForSubscription: (subscriptionKey) ->
			producerClass = @subscriptionKeyToProducerMap[subscriptionKey]

			throw "No producer found for subscription #{subscriptionKey}!" unless producerClass
			producerClass

		findProducerClassForQuery: (queryKey) ->
			producerClass = @queryKeyToProducerMap[queryKey]

			throw "No producer found for query #{queryKey}!" unless producerClass
			producerClass
