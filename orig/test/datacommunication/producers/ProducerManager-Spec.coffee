define (require) ->

	Producer = require 'datacommunication/producers/Producer'
	ProducerManager = require 'datacommunication/producers/ProducerManager'

	dataCommunicationManager = require 'datacommunication/DataCommunicationManager'

	# producerManager = undefined

	INVALID_SUBSCRIPTION_KEY = 'invalid-key'
	MOST_POPULAR_EVENTS = MOST_POPULAR_EVENTS_KEY = 'mostpopularstub'
	LIVE_EVENTS = LIVE_EVENTS_KEY = 'livestub'

	class ProducerStub extends Producer
		subscribe: ->
		unsubscribe: ->
		dispose: ->

	class MostPopularProducerStub extends ProducerStub
		SUBSCRIPTION_KEYS: [MOST_POPULAR_EVENTS_KEY]
		NAME: MOST_POPULAR_EVENTS

	class LiveEventsProducerStub extends ProducerStub
		SUBSCRIPTION_KEYS: [LIVE_EVENTS_KEY]
		NAME: LIVE_EVENTS


	describe 'A ProducerManager', ->

		beforeEach ->
			ProducerManager.constructor()
			dataCommunicationManager.registerProducers [MostPopularProducerStub, LiveEventsProducerStub]

		describe 'given a valid subscription key', ->

			it 'should return the producer', ->
				producer = ProducerManager.producerForKey MOST_POPULAR_EVENTS_KEY
				(expect producer instanceof MostPopularProducerStub).toBe true

			it 'should return the correct producer', ->
				producer1 = ProducerManager.producerForKey MOST_POPULAR_EVENTS_KEY
				producer2 = ProducerManager.producerForKey LIVE_EVENTS_KEY
				expect(producer2).not.toEqual(producer1)

			describe 'to subscribe', ->
				it 'should call the producer\'s addComponent method', ->
					options = {}
					spyOn MostPopularProducerStub.prototype, 'addComponent'
					ProducerManager.subscribeComponentToKey MOST_POPULAR_EVENTS_KEY, options
					(expect MostPopularProducerStub.prototype.addComponent.calls.length).toBe 1
					(expect MostPopularProducerStub.prototype.addComponent.calls[0].object instanceof MostPopularProducerStub).toBe true
					args = MostPopularProducerStub.prototype.addComponent.calls[0].args
					(expect args.length).toBe 2
					(expect args[0]).toBe MOST_POPULAR_EVENTS
					(expect args[1]).toBe options

			describe 'to unsubscribe', ->
				it 'should call the producer\'s removeComponent method', ->
					componentId = 'dummy'

					spyOn MostPopularProducerStub.prototype, 'removeComponent'

					ProducerManager.unsubscribeComponentFromKey MOST_POPULAR_EVENTS_KEY, componentId

					(expect MostPopularProducerStub.prototype.removeComponent.calls.length).toBe 1
					(expect MostPopularProducerStub.prototype.removeComponent.calls[0].object instanceof MostPopularProducerStub).toBe true
					args = MostPopularProducerStub.prototype.removeComponent.calls[0].args
					(expect args.length).toBe 2
					(expect args[0]).toBe MOST_POPULAR_EVENTS
					(expect args[1]).toBe componentId

		describe 'given a invalid subscription key', ->

			it 'should throw an exception', ->
				(expect (-> ProducerManager.getProducer INVALID_SUBSCRIPTION_KEY)).toThrow()


