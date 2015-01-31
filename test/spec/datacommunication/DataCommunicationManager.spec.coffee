assert = require 'assert'
sinon = require 'sinon'

DataCommunicationManager = Vigor.DataCommunicationManager
SubscriptionKeys = Vigor.SubscriptionKeys.extend
  NEW_MOST_POPULAR_EVENTS: 'new_most_popular_events'

exampleComponent_1 = undefined
exampleComponent_2 = undefined
dataCommunicationManager = undefined

class DummyProducer extends Vigor.Producer
  subscribe: ->
  SUBSCRIPTION_KEYS: [SubscriptionKeys.NEW_MOST_POPULAR_EVENTS]
  NAME: 'DummyProducer'

describe 'A DataCommunicationManager', ->
  beforeEach ->
    dataCommunicationManager = DataCommunicationManager.makeTestInstance()
    dataCommunicationManager.registerProducers DummyProducer

    exampleComponent_1 =
      id: 'ComponentId_1'
      callback: ->

    exampleComponent_2 =
      id: 'ComponentId_2'
      callback: ->

  afterEach ->
    do dataCommunicationManager.unregisterAllProducers
    dataCommunicationManager = undefined

  describe 'using subscribe', ->
    it 'should add unique component to subscription map', ->
      id = exampleComponent_1.id
      key = SubscriptionKeys.NEW_MOST_POPULAR_EVENTS
      callback = exampleComponent_1.callback
      options = {}

      dataCommunicationManager.subscribe id, key, callback, options

      subscriptionComponentList = dataCommunicationManager.subscriptionsWithComponentIdentifiers[key]
      assert.ok(subscriptionComponentList)
      assert.equal(subscriptionComponentList.length, 1)

      component = subscriptionComponentList[0]
      assert.equal(component.id, exampleComponent_1.id)
      assert.equal(component.callback, exampleComponent_1.callback)

    it 'should add multiple components for same subscription', ->
      id = exampleComponent_1.id
      key = SubscriptionKeys.NEW_MOST_POPULAR_EVENTS
      callback = exampleComponent_1.callback
      options = {}

      id2 = exampleComponent_2.id
      key = SubscriptionKeys.NEW_MOST_POPULAR_EVENTS
      callback2 = exampleComponent_2.callback

      dataCommunicationManager.subscribe id, key, callback, options
      dataCommunicationManager.subscribe id2, key, callback2, options

      subscriptionComponentList = dataCommunicationManager.subscriptionsWithComponentIdentifiers[key]
      assert.ok(subscriptionComponentList)
      assert.equal(subscriptionComponentList.length, 2)

      component1 = subscriptionComponentList[0]
      assert.equal(component1.id, id)
      assert.equal(component1.callback, callback)

      component2 = subscriptionComponentList[1]
      assert.equal(component2.id, id2)
      assert.equal(component2.callback, callback2)

    it 'should not add same component (same id) to subscription if it is already present', ->
      id = exampleComponent_1.id
      key = SubscriptionKeys.NEW_MOST_POPULAR_EVENTS
      callback = exampleComponent_1.callback
      options = {}

      dataCommunicationManager.subscribe id, key, callback, options
      dataCommunicationManager.subscribe id, key, callback, options

      subscriptionComponentList = dataCommunicationManager.subscriptionsWithComponentIdentifiers[key]
      assert.ok(subscriptionComponentList)
      assert.equal(subscriptionComponentList.length, 1)

      component = subscriptionComponentList[0]
      assert.equal(component.id, id)
      assert.equal(component.callback, callback)


  describe 'using unsubscribe', ->
    it 'should remove component from subscription map', ->
      id = exampleComponent_1.id
      key = SubscriptionKeys.NEW_MOST_POPULAR_EVENTS
      callback = exampleComponent_1.callback
      options = {}

      id2 = exampleComponent_2.id
      key = SubscriptionKeys.NEW_MOST_POPULAR_EVENTS
      callback2 = exampleComponent_2.callback

      dataCommunicationManager.subscribe id, key, callback, options
      dataCommunicationManager.subscribe id2, key, callback2, options

      subscriptionComponentList = dataCommunicationManager.subscriptionsWithComponentIdentifiers[key]
      assert.ok(subscriptionComponentList)
      assert.equal(subscriptionComponentList.length, 2)

      dataCommunicationManager.unsubscribe id, key

      assert.equal(subscriptionComponentList.length, 1)

      component = subscriptionComponentList[0]
      assert.equal(component.id, id2)
      assert.equal(component.callback, callback2)

    it 'should remove subscription if there are no components registered for that subscription', ->
      id = exampleComponent_1.id
      key = SubscriptionKeys.NEW_MOST_POPULAR_EVENTS
      callback = exampleComponent_1.callback
      options = {}

      dataCommunicationManager.subscribe id, key, callback, options

      subscriptionComponentList = dataCommunicationManager.subscriptionsWithComponentIdentifiers[key]
      assert.ok(subscriptionComponentList)
      assert.equal(subscriptionComponentList.length, 1)

      dataCommunicationManager.unsubscribe id, key
      subscriptionComponentList = dataCommunicationManager.subscriptionsWithComponentIdentifiers[key]
      assert.equal(subscriptionComponentList, undefined)

