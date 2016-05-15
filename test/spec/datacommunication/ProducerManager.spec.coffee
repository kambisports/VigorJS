Vigor = require '../../../dist/vigor'
assert = require 'assert'
sinon = require 'sinon'

dataCommunicationManager = Vigor.DataCommunicationManager
producerManager = Vigor.ProducerManager
producerMapper = Vigor.ProducerMapper

SubscriptionKeys = Vigor.SubscriptionKeys.extend {

  EXAMPLE_KEY1:
    key: 'example-key'
    contract:
      val1: []
      val2: undefined
      val3: undefined
      val4: false
      val5: true
      val6: {}
      val7: 'string'
      val8: 123

  EXAMPLE_KEY2:
    key: 'example-key2'
    contract:
      val1: 'string'
}

INVALID_SUBSCRIPTION_KEY = 'invalid-key'

class ProducerStub extends Vigor.Producer
  subscribe: ->
  unsubscribe: ->
  subscribeToRepositories: ->
  dispose: ->

class DummyProducer1 extends ProducerStub
  PRODUCTION_KEY: SubscriptionKeys.EXAMPLE_KEY1

class DummyProducer2 extends ProducerStub
  PRODUCTION_KEY: SubscriptionKeys.EXAMPLE_KEY2

addComponent = sinon.spy DummyProducer1.prototype, 'addComponent'
removeComponent = sinon.spy DummyProducer1.prototype, 'removeComponent'
removeComponent2 = sinon.spy DummyProducer2.prototype, 'removeComponent'

describe 'A ProducerManager', ->
  beforeEach ->
    producerManager.registerProducers [DummyProducer1, DummyProducer2]

  afterEach ->
    do producerMapper.reset

  describe 'given a valid subscription key', ->

    it 'should return the producer', ->
      producer = producerManager.producerForKey SubscriptionKeys.EXAMPLE_KEY1
      assert.ok producer instanceof DummyProducer1

    it 'should return the correct producer', ->
      producer1 = producerManager.producerForKey SubscriptionKeys.EXAMPLE_KEY1
      producer2 = producerManager.producerForKey SubscriptionKeys.EXAMPLE_KEY2
      assert.notEqual producer2, producer1

    describe 'to subscribe', ->
      it 'should call the producer\'s addComponent method', ->

        addComponent.reset()
        callback = ->
        id = 123
        options = {}
        producerManager.subscribe id, SubscriptionKeys.EXAMPLE_KEY1, callback, options

        instance = addComponent.thisValues[0]
        args = addComponent.args[0]

        assert addComponent.calledOnce
        assert.ok instance instanceof DummyProducer1

        assert.equal args.length, 1
        subscription = args[0]
        assert.equal subscription.id, id
        assert.equal subscription.callback, callback
        assert.equal subscription.options, options

      it 'should add multiple components for same subscription', ->
        
        addComponent.reset()
        
        component1 =
          id: 123
          key: SubscriptionKeys.EXAMPLE_KEY1
          callback: ->
          options: {}

        component2 =
          id: 456
          key: SubscriptionKeys.EXAMPLE_KEY1
          callback: ->
          options: {}

        producerManager.subscribe component1.id, component1.key, component1.callback, component1.options
        producerManager.subscribe component2.id, component2.key, component2.callback, component2.options

        assert addComponent.calledTwice
        subscription = addComponent.lastCall.args[0]
        assert.equal subscription.id, component2.id
        assert.equal subscription.callback, component2.callback
        assert.equal subscription.options, component2.options

    describe 'to unsubscribe', ->
      it 'should call the producer\'s removeComponent method', ->
        componentId = 'dummy'

        removeComponent.reset()
        producerManager.unsubscribe componentId, SubscriptionKeys.EXAMPLE_KEY1

        instance = removeComponent.thisValues[0]
        args = removeComponent.args[0]

        assert removeComponent.calledOnce
        assert.ok instance instanceof DummyProducer1

        assert.equal args.length, 1
        assert.equal args[0], componentId

    describe 'to unsubscribe component completely', ->
      it 'should call all producers\' removeComponent method', ->
        componentId = 'dummy'

        removeComponent.reset()
        producerManager.unsubscribeAll componentId

        instance = removeComponent.thisValues[0]
        args = removeComponent.args[0]

        assert removeComponent.calledOnce
        assert.ok instance instanceof DummyProducer1

        assert.equal args.length, 1
        assert.equal args[0], componentId

        # make the same checks for the second producer
        instance = removeComponent2.thisValues[0]
        args = removeComponent2.args[0]

        assert removeComponent2.calledOnce
        assert.ok instance instanceof DummyProducer2

        assert.equal args.length, 1
        assert.equal args[0], componentId

    describe 'using subscribe', ->
      it 'should add multiple components for same subscription', ->
