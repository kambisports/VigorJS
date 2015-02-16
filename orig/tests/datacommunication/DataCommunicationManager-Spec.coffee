define (require) ->

	DataCommunicationManager = require 'datacommunication/DataCommunicationManager'
	SubscriptionKeys = require 'datacommunication/SubscriptionKeys'

	dataCommunicationManager = undefined
	exampleComponent_1 = undefined
	exampleComponent_2 = undefined

	describe 'A DataCommunicationManager', ->

		beforeEach ->
			dataCommunicationManager = DataCommunicationManager.makeTestInstance()

			exampleComponent_1 =
				id: 'ComponentId_1'
				callback: ->

			exampleComponent_2 =
				id: 'ComponentId_2'
				callback: ->

		afterEach ->
			dataCommunicationManager = undefined

		describe 'using subscribe', ->

			it 'should add unique component to subscription map', ->
				dataCommunicationManager.subscribe exampleComponent_1.id, SubscriptionKeys.MOST_POPULAR_EVENTS, exampleComponent_1.callback, {}

				subscriptionComponentList = dataCommunicationManager.subscriptionsWithComponentIdentifiers.get SubscriptionKeys.MOST_POPULAR_EVENTS
				expect(subscriptionComponentList).toBeDefined()
				expect(subscriptionComponentList.length).toBe(1)

				component = subscriptionComponentList[0]
				expect(component.id).toBe exampleComponent_1.id
				expect(component.callback).toBe exampleComponent_1.callback

			it 'should add multiple components for same subscription', ->

				dataCommunicationManager.subscribe exampleComponent_1.id, SubscriptionKeys.MOST_POPULAR_EVENTS, exampleComponent_1.callback, {}
				dataCommunicationManager.subscribe exampleComponent_2.id, SubscriptionKeys.MOST_POPULAR_EVENTS, exampleComponent_2.callback, {}

				subscriptionComponentList = dataCommunicationManager.subscriptionsWithComponentIdentifiers.get SubscriptionKeys.MOST_POPULAR_EVENTS
				expect(subscriptionComponentList).toBeDefined()
				expect(subscriptionComponentList.length).toBe(2)

				component1 = subscriptionComponentList[0]
				expect(component1.id).toBe exampleComponent_1.id
				expect(component1.callback).toBe exampleComponent_1.callback

				component2 = subscriptionComponentList[1]
				expect(component2.id).toBe exampleComponent_2.id
				expect(component2.callback).toBe exampleComponent_2.callback

			it 'should not add same component (same id) to subscription if it is already present', ->
				dataCommunicationManager.subscribe exampleComponent_1.id, SubscriptionKeys.MOST_POPULAR_EVENTS, exampleComponent_1.callback, {}
				dataCommunicationManager.subscribe exampleComponent_1.id, SubscriptionKeys.MOST_POPULAR_EVENTS, exampleComponent_1.callback, {}

				subscriptionComponentList = dataCommunicationManager.subscriptionsWithComponentIdentifiers.get SubscriptionKeys.MOST_POPULAR_EVENTS
				expect(subscriptionComponentList).toBeDefined()
				expect(subscriptionComponentList.length).toBe(1)

				component = subscriptionComponentList[0]
				expect(component.id).toBe exampleComponent_1.id
				expect(component.callback).toBe exampleComponent_1.callback

		describe 'using unsubscribe', ->

			it 'should remove component from subscription map', ->
				dataCommunicationManager.subscribe exampleComponent_1.id, SubscriptionKeys.MOST_POPULAR_EVENTS, exampleComponent_1.callback, {}
				dataCommunicationManager.subscribe exampleComponent_2.id, SubscriptionKeys.MOST_POPULAR_EVENTS, exampleComponent_2.callback, {}

				subscriptionComponentList = dataCommunicationManager.subscriptionsWithComponentIdentifiers.get SubscriptionKeys.MOST_POPULAR_EVENTS
				expect(subscriptionComponentList).toBeDefined()
				expect(subscriptionComponentList.length).toBe(2)

				dataCommunicationManager.unsubscribe exampleComponent_1.id, SubscriptionKeys.MOST_POPULAR_EVENTS

				expect(subscriptionComponentList.length).toBe(1)

				component = subscriptionComponentList[0]
				expect(component.id).toBe exampleComponent_2.id
				expect(component.callback).toBe exampleComponent_2.callback

			it 'should remove subscription if there are no components registered for that subscription', ->
				dataCommunicationManager.subscribe exampleComponent_1.id, SubscriptionKeys.MOST_POPULAR_EVENTS, exampleComponent_1.callback, {}

				subscriptionComponentList = dataCommunicationManager.subscriptionsWithComponentIdentifiers.get SubscriptionKeys.MOST_POPULAR_EVENTS
				expect(subscriptionComponentList).toBeDefined()
				expect(subscriptionComponentList.length).toBe(1)

				dataCommunicationManager.unsubscribe exampleComponent_1.id, SubscriptionKeys.MOST_POPULAR_EVENTS
				subscriptionComponentList = dataCommunicationManager.subscriptionsWithComponentIdentifiers.get SubscriptionKeys.MOST_POPULAR_EVENTS
				expect(subscriptionComponentList).toBeUndefined()

		describe 'using unsubscribeAll', ->

			it 'should remove component from all its subscriptions in map', ->
				dataCommunicationManager.subscribe exampleComponent_1.id, SubscriptionKeys.MOST_POPULAR_EVENTS, exampleComponent_1.callback, {}
				dataCommunicationManager.subscribe exampleComponent_2.id, SubscriptionKeys.MOST_POPULAR_EVENTS, exampleComponent_2.callback, {}

				subscriptionComponentList = dataCommunicationManager.subscriptionsWithComponentIdentifiers.get SubscriptionKeys.MOST_POPULAR_EVENTS
				expect(subscriptionComponentList).toBeDefined()
				expect(subscriptionComponentList.length).toBe(2)

				dataCommunicationManager.unsubscribeAll exampleComponent_1.id

				expect(subscriptionComponentList.length).toBe(1)

				component = subscriptionComponentList[0]
				expect(component.id).toBe exampleComponent_2.id
				expect(component.callback).toBe exampleComponent_2.callback

			it 'should remove subscriptions with no components registered for those subscriptions', ->
				dataCommunicationManager.subscribe exampleComponent_1.id, SubscriptionKeys.MOST_POPULAR_EVENTS, exampleComponent_1.callback, {}
				dataCommunicationManager.subscribe exampleComponent_2.id, SubscriptionKeys.MOST_POPULAR_EVENTS, exampleComponent_2.callback, {}

				subscriptionComponentList = dataCommunicationManager.subscriptionsWithComponentIdentifiers.get SubscriptionKeys.MOST_POPULAR_EVENTS
				expect(subscriptionComponentList).toBeDefined()
				expect(subscriptionComponentList.length).toBe(2)

				dataCommunicationManager.unsubscribeAll exampleComponent_1.id
				dataCommunicationManager.unsubscribeAll exampleComponent_2.id

				subscriptionComponentList = dataCommunicationManager.subscriptionsWithComponentIdentifiers.get SubscriptionKeys.MOST_POPULAR_EVENTS
				expect(subscriptionComponentList).toBeUndefined()
