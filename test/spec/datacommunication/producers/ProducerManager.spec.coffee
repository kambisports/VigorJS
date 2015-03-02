assert = require 'assert'
sinon = require 'sinon'
sandbox = undefined

DataCommunicationManager = Vigor.DataCommunicationManager
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


dataCommunicationManager = undefined
producerManager = undefined

class DummyProducer extends Vigor.Producer
  subscribe: ->
  SUBSCRIPTION_KEYS: [SubscriptionKeys.NEW_MOST_POPULAR_EVENTS]
  NAME: 'DummyProducer'

describe 'A ProducerManager', ->

  beforeEach ->
    sandbox = sinon.sandbox.create()
    dataCommunicationManager = DataCommunicationManager.makeTestInstance()
    producerManager = dataCommunicationManager.producerManager
    dataCommunicationManager.registerProducers DummyProducer

  afterEach ->
    do dataCommunicationManager.unregisterAllProducers
    do sandbox.restore
    producerManager = undefined

  describe 'given a valid subscription key', ->
    describe 'to create', ->
      it 'should return a new instance of producer if one has not been instansiated', ->
        key = SubscriptionKeys.NEW_MOST_POPULAR_EVENTS
        producer = producerManager.getProducer key
        assert.ok(producer)

      it 'should return exisiting producer if one has already been instansiated', ->
        key = SubscriptionKeys.NEW_MOST_POPULAR_EVENTS
        producer1 = producerManager.getProducer key
        producer2 = producerManager.getProducer key
        assert.equal(producer2, producer1)

    describe 'to remove', ->
      it 'should dispose the producer and remove it from list of producers', ->
        key = SubscriptionKeys.NEW_MOST_POPULAR_EVENTS
        producer = producerManager.getProducer key
        sandbox.stub(producer, 'dispose')

        producerManager.removeProducer key
        sinon.assert.calledOnce(producer.dispose)
        assert.equal(producerManager.instansiatedProducers[producer.NAME], undefined)

    describe 'given a invalid subscription key', ->
      it 'should throw an exception', ->
        subscriptionKey =
          key: 'InvalidSubscriptionKey'
          contract:
            key1: 'string'

        errorFn = -> producerManager.getProducer subscriptionKey
        assert.throws (-> errorFn()), /No producer found for subscription InvalidSubscriptionKey!/

