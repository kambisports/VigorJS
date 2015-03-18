define (require) ->

	Producer = require 'datacommunication/producers/Producer'
	ProducerManager = require 'datacommunication/producers/ProducerManager'
	dataCommunicationManager = require 'datacommunication/DataCommunicationManager'
	SubscriptionKeys = require 'datacommunication/SubscriptionKeys'

	exampleComponent_1 = undefined
	exampleComponent_2 = undefined

	describe 'The DataCommunicationManager', ->

		KEY = 'dummy'

		class DummyProducer extends Producer
			subscribe: ->
			dispose: ->
			SUBSCRIPTION_KEYS: [KEY]
			NAME: 'DummyProducer'

		beforeEach ->
			exampleComponent_1 =
				id: 'ComponentId_1'
				callback: ->

			exampleComponent_2 =
				id: 'ComponentId_2'
				callback: ->

			dataCommunicationManager.registerProducers [DummyProducer]

			spyOn ProducerManager, 'subscribeComponentToKey'
			spyOn ProducerManager, 'unsubscribeComponentFromKey'
			spyOn ProducerManager, 'unsubscribeComponent'

		describe 'using subscribe', ->

			it 'should add unique component to subscription map', ->
				options = {}

				dataCommunicationManager.subscribe exampleComponent_1.id, KEY, exampleComponent_1.callback, options

				(expect ProducerManager.subscribeComponentToKey.calls.length).toBe 1
				args = ProducerManager.subscribeComponentToKey.calls[0].args
				(expect args.length).toBe 2
				(expect args[0]).toBe KEY
				subscription = args[1]
				(expect subscription.id).toBe exampleComponent_1.id
				(expect subscription.callback).toBe exampleComponent_1.callback
				(expect subscription.options).toBe options

			it 'should add multiple components for same subscription', ->
				options2 = {}
				dataCommunicationManager.subscribe exampleComponent_1.id, KEY, exampleComponent_1.callback, {}
				dataCommunicationManager.subscribe exampleComponent_2.id, KEY, exampleComponent_2.callback, options2

				(expect ProducerManager.subscribeComponentToKey.calls.length).toBe 2
				args = ProducerManager.subscribeComponentToKey.calls[1].args
				(expect args.length).toBe 2
				(expect args[0]).toBe KEY
				subscription = args[1]
				(expect subscription.id).toBe exampleComponent_2.id
				(expect subscription.callback).toBe exampleComponent_2.callback
				(expect subscription.options).toBe options2


		describe 'using unsubscribe', ->

			it 'should remove component from subscription map', ->
				dataCommunicationManager.unsubscribe exampleComponent_1.id, KEY

				(expect ProducerManager.unsubscribeComponentFromKey.calls.length).toBe 1
				args = ProducerManager.unsubscribeComponentFromKey.calls[0].args
				(expect args.length).toBe 2
				(expect args[0]).toBe KEY
				(expect args[1]).toBe exampleComponent_1.id


		describe 'using unsubscribeAll', ->

			it 'should remove component from all its subscriptions in map', ->
				dataCommunicationManager.unsubscribeAll exampleComponent_1.id

				(expect ProducerManager.unsubscribeComponent.calls.length).toBe 1
				args = ProducerManager.unsubscribeComponent.calls[0].args
				(expect args.length).toBe 1
				(expect args[0]).toBe exampleComponent_1.id
