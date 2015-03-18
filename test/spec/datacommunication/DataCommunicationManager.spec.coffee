Vigor = require '../../../dist/backbone.vigor'
assert = require 'assert'
sinon = require 'sinon'

dataCommunicationManager = Vigor.DataCommunicationManager
producerManager = Vigor.ProducerManager

SubscriptionKeys = Vigor.SubscriptionKeys.extend {
  EXAMPLE_KEY:
    key: 'dummy-key'
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

class DummyProducer extends Vigor.Producer
  dispose: ->
  subscribe: ->
  subscribeToRepositories: ->
  SUBSCRIPTION_KEYS: [SubscriptionKeys.EXAMPLE_KEY]

describe 'A DataCommunicationManager', ->
  beforeEach ->
    dataCommunicationManager.registerProducers [DummyProducer]

    producerManager.subscribeComponentToKey = sinon.spy()
    producerManager.unsubscribeComponentFromKey = sinon.spy()
    producerManager.unsubscribeComponent = sinon.spy()

    exampleComponent1 =
      id: 'ComponentId1'
      callback: ->

    exampleComponent2 =
      id: 'ComponentId2'
      callback: ->

  describe 'using subscribe', ->
    it 'should add unique component to subscription map', ->

      id = exampleComponent1.id
      key = SubscriptionKeys.EXAMPLE_KEY
      callback = exampleComponent1.callback
      options = {}

      dataCommunicationManager.subscribe id, key, callback, options

      args = producerManager.subscribeComponentToKey.lastCall.args
      subscription = args[1]

      assert producerManager.subscribeComponentToKey.calledOnce
      assert.equal args.length, 2
      assert.equal args[0], key

      assert.equal subscription.id, id
      assert.equal subscription.callback, callback
      assert.equal subscription.options, options

    it 'should add multiple components for same subscription', ->
      id = exampleComponent1.id
      key = SubscriptionKeys.EXAMPLE_KEY
      callback = exampleComponent1.callback
      options = {}

      id2 = exampleComponent2.id
      key = SubscriptionKeys.EXAMPLE_KEY
      callback2 = exampleComponent2.callback
      options2 = {}

      dataCommunicationManager.subscribe id, key, callback, options
      dataCommunicationManager.subscribe id2, key, callback2, options2

      args = producerManager.subscribeComponentToKey.lastCall.args

      assert producerManager.subscribeComponentToKey.calledTwice
      assert.equal args.length, 2
      assert.equal args[0], key

      subscription = args[1]
      assert.equal subscription.id, id2
      assert.equal subscription.callback, callback2
      assert.equal subscription.options, options2

    # it 'should not add same component (same id) to subscription if it is already present', ->
    #   id = exampleComponent1.id
    #   key = SubscriptionKeys.EXAMPLE_KEY
    #   callback = exampleComponent1.callback
    #   options = {}

    #   dataCommunicationManager.subscribe id, key, callback, options
    #   dataCommunicationManager.subscribe id, key, callback, options

    #   subscriptionComponentList = dataCommunicationManager.getSubscriptionsWithSubscriptionKey key
    #   assert.ok(subscriptionComponentList)
    #   assert.equal(subscriptionComponentList.length, 1)

    #   component = subscriptionComponentList[0]
    #   assert.equal(component.id, id)
    #   assert.equal(component.callback, callback)


  describe 'using unsubscribe', ->
    it 'should remove component from subscription map', ->
      id = exampleComponent1.id
      key = SubscriptionKeys.EXAMPLE_KEY

      dataCommunicationManager.unsubscribe id, key

      args = producerManager.unsubscribeComponentFromKey.lastCall.args
      assert producerManager.unsubscribeComponentFromKey.calledOnce

      assert.equal args.length, 2
      assert.equal args[0], key
      assert.equal args[1], id

  describe 'using unsubscribeAll', ->
    it 'should remove component from all its subscriptions in map', ->
      id = exampleComponent1.id
      dataCommunicationManager.unsubscribeAll id

      args = producerManager.unsubscribeComponent.lastCall.args
      assert producerManager.unsubscribeComponent.calledOnce

      assert.equal args.length, 1
      assert.equal args[0], id

  #   it 'should remove subscription if there are no components registered for that subscription', ->
  #     id = exampleComponent1.id
  #     key = SubscriptionKeys.EXAMPLE_KEY
  #     callback = exampleComponent1.callback
  #     options = {}

  #     dataCommunicationManager.subscribe id, key, callback, options

  #     subscriptionComponentList = dataCommunicationManager.getSubscriptionsWithSubscriptionKey key
  #     assert.ok(subscriptionComponentList)
  #     assert.equal(subscriptionComponentList.length, 1)

  #     dataCommunicationManager.unsubscribe id, key
  #     subscriptionComponentList = dataCommunicationManager.getSubscriptionsWithSubscriptionKey key
  #     assert.equal(subscriptionComponentList, undefined)

