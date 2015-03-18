define (require) ->
	
	Producer = require 'datacommunication/producers/Producer'
	ComponentIdentifier = require 'datacommunication/ComponentIdentifier'

	KEY = 'dummy'
	KEY2 = 'ymmud'
	INVALID_SUBSCRIPTION_KEY = 'invalid-key'

	class DummyProducer extends Producer
		SUBSCRIPTION_KEYS: [KEY, KEY2]
		subscribe: jasmine.createSpy()
		subscribeToRepositories: jasmine.createSpy()
		unsubscribeFromRepositories: jasmine.createSpy()
		NAME: 'DummyProducer'

	describe 'A Producer', ->
		it 'creates subscriptionKeyToComponents for each key', ->
			producer = new DummyProducer()

			_.each producer.SUBSCRIPTION_KEYS, (key) ->
				componentsMap = producer.subscriptionKeyToComponents[key]
				(expect typeof componentsMap).toBe 'object'
				(expect (Object.keys componentsMap).length).toBe 0

		it 'adds a component', ->
			producer = new DummyProducer()
			componentIdentifier = new ComponentIdentifier 'foo', jasmine.createSpy(), {}

			producer.addComponent KEY, componentIdentifier

			componentsForKey = producer.subscriptionKeyToComponents[KEY]
			(expect (Object.keys componentsForKey).length).toBe 1
			(expect componentsForKey[componentIdentifier.id]).toBe componentIdentifier

		it 'calls subscribeToRepositories when the first component is added', ->
			producer = new DummyProducer()
			producer.subscribeToRepositories = jasmine.createSpy()

			componentIdentifier = new ComponentIdentifier 'foo', jasmine.createSpy(), {}

			producer.addComponent KEY, componentIdentifier

			(expect producer.subscribeToRepositories.calls.length).toBe 1

		it 'does not call subscribeToRepositories when a second component is added', ->
			producer = new DummyProducer()
			producer.subscribeToRepositories = jasmine.createSpy()
			componentIdentifier = new ComponentIdentifier 'foo', jasmine.createSpy(), {}
			componentIdentifier2 = new ComponentIdentifier 'bar', jasmine.createSpy(), {}

			producer.addComponent KEY, componentIdentifier
			producer.addComponent KEY, componentIdentifier2

			(expect producer.subscribeToRepositories.calls.length).toBe 1

		it 'calls unsubscribeFromRepositories when the last component is removed', ->
			producer = new DummyProducer()
			producer.unsubscribeFromRepositories = jasmine.createSpy()

			componentId = 'foo'

			componentIdentifier = new ComponentIdentifier componentId, jasmine.createSpy(), {}

			producer.addComponent KEY, componentIdentifier
			producer.removeComponent KEY, componentId

			(expect producer.unsubscribeFromRepositories.calls.length).toBe 1

		it 'does not call unsubscribeFromRepositories when there are still components subscribed', ->
			producer = new DummyProducer()
			producer.unsubscribeFromRepositories = jasmine.createSpy()

			componentId = 'foo'
			componentId2 = 'bar'

			componentIdentifier = new ComponentIdentifier componentId, jasmine.createSpy(), {}
			componentIdentifier2 = new ComponentIdentifier componentId2, jasmine.createSpy(), {}

			producer.addComponent KEY, componentIdentifier
			producer.addComponent KEY, componentIdentifier2
			producer.removeComponent KEY, componentId

			(expect producer.unsubscribeFromRepositories.calls.length).toBe 0

		it 'throws an error if the key is not known', ->
			producer = new DummyProducer()

			(expect -> (producer.addComponent INVALID_SUBSCRIPTION_KEY)).toThrow()

		it 'removes a component from a key', ->
			producer = new DummyProducer()
			componentIdentifier = new ComponentIdentifier 'foo', jasmine.createSpy(), {}

			producer.addComponent KEY, componentIdentifier
			producer.removeComponent KEY, componentIdentifier.id

			(expect (Object.keys producer.subscriptionKeyToComponents[KEY]).length).toBe 0

		it 'removes a component entirely', ->
			componentId = 'foo'

			producer = new DummyProducer()

			componentIdentifier1 = new ComponentIdentifier componentId, jasmine.createSpy(), {}
			componentIdentifier2 = new ComponentIdentifier componentId, jasmine.createSpy(), {}

			producer.addComponent KEY, componentIdentifier1
			producer.addComponent KEY2, componentIdentifier2

			producer.removeComponent componentId

			(expect (Object.keys producer.subscriptionKeyToComponents[KEY]).length).toBe 0
			(expect (Object.keys producer.subscriptionKeyToComponents[KEY2]).length).toBe 0


		it 'does not remove components if they are not added', ->
			producer = new DummyProducer()
			componentIdentifier = new ComponentIdentifier 'foo', jasmine.createSpy(), {}

			producer.removeComponent KEY, componentIdentifier.id

			(expect (Object.keys producer.subscriptionKeyToComponents[KEY]).length).toBe 0

		it 'does not remove unrelated components', ->
			producer = new DummyProducer()
			componentIdentifier1 = new ComponentIdentifier 'foo', jasmine.createSpy(), {}
			componentIdentifier2 = new ComponentIdentifier 'bar', jasmine.createSpy(), {}

			producer.addComponent KEY, componentIdentifier1
			producer.addComponent KEY, componentIdentifier2
			producer.removeComponent KEY, componentIdentifier2.id

			(expect (Object.keys producer.subscriptionKeyToComponents[KEY]).length).toBe 1
			(expect producer.subscriptionKeyToComponents[KEY][componentIdentifier1.id]).toBe componentIdentifier1

		it 'does not remove subscriptions on different keys', ->
			producer = new DummyProducer()
			componentIdentifier = new ComponentIdentifier 'foo', jasmine.createSpy(), {}

			producer.addComponent KEY, componentIdentifier
			producer.addComponent KEY2, componentIdentifier
			producer.removeComponent KEY, componentIdentifier.id

			(expect (Object.keys producer.subscriptionKeyToComponents[KEY]).length).toBe 0
			(expect (Object.keys producer.subscriptionKeyToComponents[KEY2]).length).toBe 1

		it 'produces data', ->
			producer = new DummyProducer()
			callback = jasmine.createSpy()
			producedData = {}
			componentIdentifier = new ComponentIdentifier 'foo', callback, {}

			producer.addComponent KEY, componentIdentifier

			producer.produce KEY, producedData

			(expect callback.calls.length).toBe 1
			args = callback.calls[0].args
			(expect args.length).toBe 1
			(expect args[0]).toBe producedData

		it 'does not produce data on the wrong key', ->
			producer = new DummyProducer()
			callback = jasmine.createSpy()
			producedData = {}
			componentIdentifier = new ComponentIdentifier 'foo', callback, {}

			producer.addComponent KEY, componentIdentifier

			producer.produce KEY2, producedData

			(expect callback.calls.length).toBe 0

		it 'does not call filter if the options was empty', ->
			producer = new DummyProducer()
			callback = jasmine.createSpy()
			filter = jasmine.createSpy()
			producedData = {}
			componentIdentifier = new ComponentIdentifier 'foo', callback, {}

			producer.addComponent KEY, componentIdentifier

			producer.produce KEY, producedData, filter

			(expect callback.calls.length).toBe 1
			args = callback.calls[0].args
			(expect args.length).toBe 1
			(expect args[0]).toBe producedData
			(expect filter.calls.length).toBe 0

		it 'calls filter if the options were not empty', ->
			producer = new DummyProducer()
			callback = jasmine.createSpy()
			filter = jasmine.createSpy()
			options =
				foo: 'bar'

			producedData = {}

			componentIdentifier = new ComponentIdentifier 'foo', callback, options

			producer.addComponent KEY, componentIdentifier

			producer.produce KEY, producedData, filter

			(expect filter.calls.length).toBe 1
			(expect filter.calls[0].args.length).toBe 1
			(expect filter.calls[0].args[0]).toBe options

		it 'calls the callback if the filter returns true', ->
			producer = new DummyProducer()
			callback = jasmine.createSpy()
			filter = jasmine.createSpy().andReturn true
			options =
				foo: 'bar'

			producedData = {}
			componentIdentifier = new ComponentIdentifier 'foo', callback, options

			producer.addComponent KEY, componentIdentifier

			producer.produce KEY, producedData, filter

			(expect callback.calls.length).toBe 1
			args = callback.calls[0].args
			(expect args.length).toBe 1
			(expect args[0]).toBe producedData

		it 'does not call the callback if the filter returns false', ->
			producer = new DummyProducer()
			callback = jasmine.createSpy()
			filter = jasmine.createSpy().andReturn false
			options =
				foo: 'bar'

			producedData = {}
			componentIdentifier = new ComponentIdentifier 'foo', callback, options

			producer.addComponent KEY, componentIdentifier

			producer.produce KEY, producedData, filter

			(expect callback.calls.length).toBe 0
