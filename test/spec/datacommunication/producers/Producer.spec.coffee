Vigor = require '../../../../dist/backbone.vigor'
assert = require 'assert'
sinon = require 'sinon'
sandbox = undefined

SubscriptionKey =
  key: 'dummy'
  contract:
    key1: 'string'

class DummyProducer extends Vigor.Producer
  subscribe: ->
  dispose: ->
  SUBSCRIPTION_KEYS: [SubscriptionKey]
  NAME: 'DummyProducer'

exampleComponent1 =
  id: 'ComponentId1'
  callback: ->

exampleComponent2 =
  id: 'ComponentId2'
  callback: ->


describe 'A Producer', ->
  producer = undefined
  componentIdentifier = undefined
  componentIdentifier2 = undefined

  beforeEach ->
    producer = new DummyProducer()

    componentId = exampleComponent1.id
    callback = exampleComponent1.callback
    options = {}

    componentId2 = exampleComponent2.id
    callback2 = exampleComponent2.callback
    options2 = {}

    componentIdentifier = new Vigor.ComponentIdentifier(componentId, callback, options)
    componentIdentifier2 = new Vigor.ComponentIdentifier(componentId2, callback2, options2)

  afterEach ->
    producer = undefined
    componentIdentifier = undefined
    componentIdentifier2 = undefined

  describe 'on creation', ->
    it 'it should add its subscription keys to its subscriptionKeyToComponents map', ->
      addKeysToMap = sinon.spy DummyProducer.prototype, '_addKeysToMap'
      producer = new DummyProducer()
      sinon.assert.calledOnce(addKeysToMap)
      assert.deepEqual(producer.subscriptionKeyToComponents[SubscriptionKey.key], [])

  describe 'when adding a component for subscription', ->
    it 'it should throw an "Unknown subscription key" error if the passed key is not registered', ->
      errorFn = -> producer.addComponent('none-exsisting-key', componentIdentifier)
      assert.throws (-> errorFn()), /Unknown subscription key, could not add component!/

    it 'it should store a component identifier on the subscription key in the subscriptionKeyToComponents map', ->
      producer.addComponent SubscriptionKey, componentIdentifier
      assert.deepEqual(producer.subscriptionKeyToComponents[SubscriptionKey.key], [componentIdentifier])

  describe 'when producing data for components', ->
    it 'it should call callbacks with produdced data for all components that subscribed on a key', ->
      producer.addComponent SubscriptionKey, componentIdentifier
      producer.addComponent SubscriptionKey, componentIdentifier2

      dummyData =
        key1: 'string'

      spiedCallback = sinon.spy componentIdentifier, 'callback'
      spiedCallback2 = sinon.spy componentIdentifier2, 'callback'

      producer.produce SubscriptionKey, dummyData
      sinon.assert.calledOnce(spiedCallback)
      sinon.assert.calledOnce(spiedCallback2)
      assert spiedCallback.calledWith(dummyData)
      assert spiedCallback2.calledWith(dummyData)

