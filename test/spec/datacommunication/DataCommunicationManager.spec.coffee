Vigor = require '../../../dist/backbone.vigor'
assert = require 'assert'
sinon = require 'sinon'

SubscriptionKeys = Vigor.SubscriptionKeys.extend {
  NEW_MOST_POPULAR_EVENTS:
    key: 'new_most_popular_events'
    contract:
      val1: []
      val2: undefined
      val3: undefined
      val4: false
      val5: true
      val6: {}
      val7: 'string'
      val8: 123
}

exampleComponent1 = undefined
exampleComponent2 = undefined
dataCommunicationManager = undefined

class DummyProducer extends Vigor.Producer
  dispose: ->
  subscribe: ->
  SUBSCRIPTION_KEYS: [SubscriptionKeys.NEW_MOST_POPULAR_EVENTS]
  NAME: 'DummyProducer'

describe 'A DataCommunicationManager', ->
  beforeEach ->
    dataCommunicationManager = Vigor.DataCommunicationManager
    dataCommunicationManager.registerProducers DummyProducer

    exampleComponent1 =
      id: 'ComponentId1'
      callback: ->

    exampleComponent2 =
      id: 'ComponentId2'
      callback: ->

  afterEach ->
    do dataCommunicationManager.unregisterAllProducers
    dataCommunicationManager.reset()

  describe 'using subscribe', ->
    it 'should add unique component to subscription map', ->
      id = exampleComponent1.id
      key = SubscriptionKeys.NEW_MOST_POPULAR_EVENTS

      callback = exampleComponent1.callback
      options = {}

      dataCommunicationManager.subscribe id, key, callback, options

      subscriptionComponentList = dataCommunicationManager.getSubscriptionsWithSubscriptionKey key
      assert.ok(subscriptionComponentList)
      assert.equal(subscriptionComponentList.length, 1)

      component = subscriptionComponentList[0]
      assert.equal(component.id, exampleComponent1.id)
      assert.equal(component.callback, exampleComponent1.callback)

    it 'should add multiple components for same subscription', ->
      id = exampleComponent1.id
      key = SubscriptionKeys.NEW_MOST_POPULAR_EVENTS
      callback = exampleComponent1.callback
      options = {}

      id2 = exampleComponent2.id
      key = SubscriptionKeys.NEW_MOST_POPULAR_EVENTS
      callback2 = exampleComponent2.callback

      dataCommunicationManager.subscribe id, key, callback, options
      dataCommunicationManager.subscribe id2, key, callback2, options

      subscriptionComponentList = dataCommunicationManager.getSubscriptionsWithSubscriptionKey key
      assert.ok(subscriptionComponentList)
      assert.equal(subscriptionComponentList.length, 2)

      component1 = subscriptionComponentList[0]
      assert.equal(component1.id, id)
      assert.equal(component1.callback, callback)

      component2 = subscriptionComponentList[1]
      assert.equal(component2.id, id2)
      assert.equal(component2.callback, callback2)

    it 'should not add same component (same id) to subscription if it is already present', ->
      id = exampleComponent1.id
      key = SubscriptionKeys.NEW_MOST_POPULAR_EVENTS
      callback = exampleComponent1.callback
      options = {}

      dataCommunicationManager.subscribe id, key, callback, options
      dataCommunicationManager.subscribe id, key, callback, options

      subscriptionComponentList = dataCommunicationManager.getSubscriptionsWithSubscriptionKey key
      assert.ok(subscriptionComponentList)
      assert.equal(subscriptionComponentList.length, 1)

      component = subscriptionComponentList[0]
      assert.equal(component.id, id)
      assert.equal(component.callback, callback)


  describe 'using unsubscribe', ->
    it 'should remove component from subscription map', ->
      id = exampleComponent1.id
      key = SubscriptionKeys.NEW_MOST_POPULAR_EVENTS
      callback = exampleComponent1.callback
      options = {}

      id2 = exampleComponent2.id
      key = SubscriptionKeys.NEW_MOST_POPULAR_EVENTS
      callback2 = exampleComponent2.callback

      dataCommunicationManager.subscribe id, key, callback, options
      dataCommunicationManager.subscribe id2, key, callback2, options

      subscriptionComponentList = dataCommunicationManager.getSubscriptionsWithSubscriptionKey key
      assert.ok(subscriptionComponentList)
      assert.equal(subscriptionComponentList.length, 2)

      dataCommunicationManager.unsubscribe id, key

      assert.equal(subscriptionComponentList.length, 1)

      component = subscriptionComponentList[0]
      assert.equal(component.id, id2)
      assert.equal(component.callback, callback2)

    it 'should remove subscription if there are no components registered for that subscription', ->
      id = exampleComponent1.id
      key = SubscriptionKeys.NEW_MOST_POPULAR_EVENTS
      callback = exampleComponent1.callback
      options = {}

      dataCommunicationManager.subscribe id, key, callback, options

      subscriptionComponentList = dataCommunicationManager.getSubscriptionsWithSubscriptionKey key
      assert.ok(subscriptionComponentList)
      assert.equal(subscriptionComponentList.length, 1)

      dataCommunicationManager.unsubscribe id, key
      subscriptionComponentList = dataCommunicationManager.getSubscriptionsWithSubscriptionKey key
      assert.equal(subscriptionComponentList, undefined)

