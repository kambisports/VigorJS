Vigor = require '../../../../dist/backbone.vigor'
assert = require 'assert'
sinon = require 'sinon'

dataCommunicationManager = Vigor.DataCommunicationManager
producerManager = Vigor.ProducerManager

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
  SUBSCRIPTION_KEYS: [SubscriptionKeys.EXAMPLE_KEY1]

class DummyProducer2 extends ProducerStub
  SUBSCRIPTION_KEYS: [SubscriptionKeys.EXAMPLE_KEY2]

describe 'A ProducerManager', ->
  beforeEach ->
    dataCommunicationManager.registerProducers [DummyProducer1, DummyProducer2]

  # afterEach ->
  #   do dataCommunicationManager.reset

  describe 'given a valid subscription key', ->

    it 'should return the producer', ->
      producer = producerManager.producerForKey SubscriptionKeys.EXAMPLE_KEY1
      assert.equal producer instanceof DummyProducer1, true

    it 'should return the correct producer', ->
      producer1 = producerManager.producerForKey SubscriptionKeys.EXAMPLE_KEY1
      producer2 = producerManager.producerForKey SubscriptionKeys.EXAMPLE_KEY2
      assert.notEqual producer2, producer1

    # describe 'to subscribe', ->
    #   it 'should call the producer\'s addComponent method', ->

    #     options = {}
    #     spyOn MostPopularProducerStub.prototype, 'addComponent'
    #     ProducerManager.subscribeComponentToKey MOST_POPULAR_EVENTS_KEY, options
    #     (expect MostPopularProducerStub.prototype.addComponent.calls.length).toBe 1
    #     (expect MostPopularProducerStub.prototype.addComponent.calls[0].object instanceof MostPopularProducerStub).toBe true
    #     args = MostPopularProducerStub.prototype.addComponent.calls[0].args
    #     (expect args.length).toBe 2
    #     (expect args[0]).toBe MOST_POPULAR_EVENTS
    #     (expect args[1]).toBe options

    # describe 'to create', ->
    #   it 'should return a new instance of producer if one has not been instansiated', ->
    #     key = SubscriptionKeysEXAMPLE_KEY.
    #     producer = producerManager.getProducer key
    #     assert.ok(producer)

    #   it 'should return exisiting producer if one has already been instansiated', ->
    #     key = SubscriptionKeysEXAMPLE_KEY.
    #     producer1 = producerManager.getProducer key
    #     producer2 = producerManager.getProducer key
    #     assert.equal(producer2, producer1)

    # describe 'to remove', ->
    #   it 'should dispose the producer and remove it from list of producers', ->
    #     key = SubscriptionKeysEXAMPLE_KEY.
    #     producer = producerManager.getProducer key
    #     sandbox.stub(producer, 'dispose')

    #     producerManager.removeProducer key
    #     sinon.assert.calledOnce(producer.dispose)
    #     assert.equal(producerManager.getProducerInstanceByName(producer.NAME), undefined)

    # describe 'given a invalid subscription key', ->
    #   it 'should throw an exception', ->
    #     subscriptionKey =
    #       key: 'InvalidSubscriptionKey'
    #       contract:
    #         key1: 'string'

    #     errorFn = -> producerManager.getProducer subscriptionKey
    #     assert.throws (-> errorFn()), /No producer found for subscription InvalidSubscriptionKey!/

