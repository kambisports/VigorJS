define (require) ->
	ProducerManager = require 'datacommunication/producers/ProducerManager'
	SubscriptionKeys = require 'datacommunication/SubscriptionKeys'

	producerManager = undefined

	describe 'A ProducerManager', ->

		beforeEach ->
			producerManager = new ProducerManager()

		describe 'given a valid subscription key', ->

			describe 'to create', ->

				it 'should return a new instance of producer if one has not been instansiated', ->
					producer = producerManager.getProducer SubscriptionKeys.NEW_MOST_POPULAR_EVENTS
					expect(producer).toBeDefined()

				it 'should return exisiting producer if one has already been instansiated', ->
					producer1 = producerManager.getProducer SubscriptionKeys.NEW_MOST_POPULAR_EVENTS
					producer2 = producerManager.getProducer SubscriptionKeys.NEW_MOST_POPULAR_EVENTS
					expect(producer2).toEqual(producer1)

			describe 'to remove', ->
				it 'should dispose the producer and remove it from list of producers', ->
					producer = producerManager.getProducer SubscriptionKeys.NEW_MOST_POPULAR_EVENTS
					spyOn producer, 'dispose'

					producerManager.removeProducer SubscriptionKeys.NEW_MOST_POPULAR_EVENTS
					expect(producer.dispose).toHaveBeenCalled()
					expect(producerManager.instansiatedProducers[producer.NAME]).toBeUndefined()

		describe 'given a invalid subscription key', ->

			it 'should throw an exception', ->
				expect ->
					producerManager.getProducer 'InvalidSubscriptionKey'
				.toThrow()


