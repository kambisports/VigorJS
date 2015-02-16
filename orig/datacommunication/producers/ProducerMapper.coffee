define (require) ->

	HelloWorldProducer = require 'datacommunication/producers/helloworld/HelloWorldProducer'
	HelloWorldsProducer = require 'datacommunication/producers/helloworld/HelloWorldsProducer'

	MostPopularProducer = require 'datacommunication/producers/mostpopular/MostPopularProducer'
	BetofferProducer = require 'datacommunication/producers/betoffer/BetofferProducer'

	HighlightedGroupsProducer = require 'datacommunication/producers/groups/HighlightedGroupsProducer'
	PersonalizedSportsProducer = require 'datacommunication/producers/groups/PersonalizedSportsProducer'
	SportsGroupsProducer = require 'datacommunication/producers/groups/SportsGroupsProducer'
	SportsGroupsATOZProducer = require 'datacommunication/producers/groups/SportsGroupsATOZProducer'

	EventProducer = require 'datacommunication/producers/events/EventProducer'
	LiveEventsProducer = require 'datacommunication/producers/events/LiveEventsProducer'

	class ProducerMapper

		#
		producers: [
			HelloWorldProducer
			HelloWorldsProducer
			MostPopularProducer
			BetofferProducer
			HighlightedGroupsProducer
			PersonalizedSportsProducer
			SportsGroupsProducer
			SportsGroupsATOZProducer
			EventProducer
			LiveEventsProducer
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
