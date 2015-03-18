define (require) ->
	Producer = require 'datacommunication/producers/Producer'
	ProducerMapper = require 'datacommunication/producers/ProducerMapper'

	producerMapper = undefined

	KEY = 'dummy'
	KEY2 = 'dummy2'

	class DummyProducer extends Producer
		subscribe: ->
		dispose: ->
		SUBSCRIPTION_KEYS: [KEY]
		NAME: 'DummyProducer'

	class DummyProducer2 extends Producer
		subscribe: ->
		dispose: ->
		SUBSCRIPTION_KEYS: [KEY, KEY2]
		NAME: 'DummyProducer2'

	describe 'A ProducerMapper', ->

		beforeEach ->
			producerMapper = new ProducerMapper()

		describe 'given a registered subscription key', ->
			it 'it should return a producerClass', ->
				producerMapper.register DummyProducer
				producer = producerMapper.producerClassForKey KEY
				(expect producer).toBe DummyProducer

			it 'it should return a producer', ->
				producerMapper.register DummyProducer
				producer = producerMapper.producerForKey KEY
				(expect producer instanceof DummyProducer).toBe true

		describe 'given a unregistered subscription key', ->
			it 'it should throw a "No producer found for subscription" error', ->
				producerMapper.register DummyProducer
				errorFn = -> producerMapper.producerClassForKey KEY2
				expect(-> errorFn()).toThrow 'No producer found for subscription dummy2!'

		describe 'when trying to find a producer when no producers are registered', ->
			it 'it should throw a "There are No producers registered" error', ->
				errorFn = -> producerMapper.producerClassForKey KEY
				expect(-> errorFn()).toThrow 'There are no producers registered - register producers through the DataCommunicationManager'
