assert = require 'assert'
sinon = require 'sinon'
sandbox = undefined

KEY = 'dummy'

class DummyProducer extends Vigor.Producer
  subscribe: ->
  dispose: ->
  SUBSCRIPTION_KEYS: [KEY]
  NAME: 'DummyProducer'

exampleComponent_1 =
  id: 'ComponentId_1'
  callback: ->


describe 'A Producer', ->
  producer = undefined
  componentIdentifier = undefined
  describe 'on creation', ->
    it 'it should add its subscription keys to its subscriptionKeyToComponents map', ->
      addKeysToMap = sinon.spy DummyProducer.prototype, '_addKeysToMap'
      producer = new DummyProducer()
      sinon.assert.calledOnce(addKeysToMap)
      assert.deepEqual(producer.subscriptionKeyToComponents[KEY], [])


  describe 'when adding a component for subscription', ->
    beforeEach ->
      producer = new DummyProducer()

      componentId = exampleComponent_1.id
      callback = exampleComponent_1.callback
      options = {}

      componentIdentifier = new Vigor.ComponentIdentifier(componentId, callback, options)

    it 'it should throw an "Unknown subscription key" error if the passed key is not registered', ->
      errorFn = -> producer.addComponent('none-exsisting-key', componentIdentifier)
      assert.throws (-> errorFn()), /Unknown subscription key, could not add component!/

    it 'it should store a component identifier on the subscription key in the subscriptionKeyToComponents map', ->
      producer.addComponent KEY, componentIdentifier
      assert.deepEqual(producer.subscriptionKeyToComponents[KEY], [componentIdentifier])
