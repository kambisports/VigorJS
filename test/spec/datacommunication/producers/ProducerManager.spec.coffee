Vigor = require '../../../../dist/backbone.vigor'
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

describe 'A ProducerManager', ->
  beforeEach ->
    dataCommunicationManager.registerProducers [DummyProducer1, DummyProducer2]

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

        options = {}

        addComponent = sinon.spy DummyProducer1.prototype, 'addComponent'
        producerManager.subscribeComponentToKey SubscriptionKeys.EXAMPLE_KEY1, options

        instance = addComponent.thisValues[0]
        args = addComponent.args[0]

        assert addComponent.calledOnce
        assert.ok instance instanceof DummyProducer1

        assert.equal args.length, 2
        assert.equal args[0], SubscriptionKeys.EXAMPLE_KEY1
        assert.equal args[1], options

    describe 'to unsubscribe', ->
      it 'should call the producer\'s removeComponent method', ->
        componentId = 'dummy'

        removeComponent = sinon.spy DummyProducer1.prototype, 'removeComponent'

        producerManager.unsubscribeComponentFromKey SubscriptionKeys.EXAMPLE_KEY1, componentId

        instance = removeComponent.thisValues[0]
        args = removeComponent.args[0]

        assert removeComponent.calledOnce
        assert.ok instance instanceof DummyProducer1

        assert.equal args.length, 2
        assert.equal args[0], SubscriptionKeys.EXAMPLE_KEY1
        assert.equal args[1], componentId

  # This method doesn't seem to exist
  # describe 'given a invalid subscription key', ->
  #   it 'should throw an exception', ->
  #     errorFn = -> producerManager.getProducer INVALID_SUBSCRIPTION_KEY
  #     assert.throws (-> errorFn()), /Unknown subscription key, could not add component!/

