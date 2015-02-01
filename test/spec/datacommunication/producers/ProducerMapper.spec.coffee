assert = require 'assert'
sinon = require 'sinon'
sandbox = undefined

KEY = 'dummy'
KEY2 = 'dummy2'

class DummyProducer extends Vigor.Producer
  subscribe: ->
  dispose: ->
  SUBSCRIPTION_KEYS: [KEY]
  NAME: 'DummyProducer'

class DummyProducer2 extends Vigor.Producer
  subscribe: ->
  dispose: ->
  SUBSCRIPTION_KEYS: [KEY, KEY2]
  NAME: 'DummyProducer2'

producerMapper = undefined

describe 'A ProducerMapper', ->
  beforeEach ->
    sandbox = sinon.sandbox.create()
    producerMapper = new Vigor.ProducerMapper()
    do producerMapper.removeAllProducers

  afterEach ->
    do sandbox.restore
    producerMapper = undefined

  describe 'given a registered subscription key', ->
    it 'it should return a producerClass', ->
      producerMapper.addProducerClass DummyProducer
      producer = producerMapper.findProducerClassForSubscription KEY
      assert.equal(producer, DummyProducer)

  describe 'given a unregistered subscription key', ->
    it 'it should throw a "No producer found for subscription" error', ->
      producerMapper.addProducerClass DummyProducer
      errorFn = -> producerMapper.findProducerClassForSubscription KEY2
      assert.throws (-> errorFn()), /No producer found for subscription dummy2!/

  describe 'when trying to find a producer when no producers are registered', ->
    it 'it should throw a "There are No producers registered" error', ->
      errorFn = -> producerMapper.findProducerClassForSubscription KEY
      assert.throws (-> errorFn()), /There are no producers registered - register producers through the DataCommunicationManager/

  describe 'given a producerClass', ->
    describe 'to add', ->
      it 'it should store the producerClass', ->
        assert.equal(producerMapper.producers.length, 0)
        producerMapper.addProducerClass DummyProducer
        assert.equal(producerMapper.producers.length, 1)
        assert.equal(producerMapper.subscriptionKeyToProducerMap[KEY], DummyProducer)

    describe 'to remove', ->
      it 'it should remove the producerClass', ->
        assert.equal(producerMapper.producers.length, 0)
        producerMapper.addProducerClass DummyProducer
        assert.equal(producerMapper.producers.length, 1)

        producerMapper.removeProducerClass DummyProducer

        assert.equal(producerMapper.producers.length, 0)
        assert.equal(producerMapper.subscriptionKeyToProducerMap[KEY], undefined)

  describe 'removing all producers', ->
      it 'it should empty storage', ->
        assert.equal(producerMapper.producers.length, 0)
        producerMapper.addProducerClass DummyProducer
        assert.equal(producerMapper.producers.length, 1)
        do producerMapper.removeAllProducers
        assert.equal(producerMapper.producers.length, 0)
        assert.equal(producerMapper.subscriptionKeyToProducerMap[KEY], undefined)

  describe 'when running _buildMap', ->
      it 'it should store the producer for each subscription key in the producer', ->
        buildMap = sinon.spy producerMapper, '_buildMap'
        producerMapper.addProducerClass DummyProducer2

        assert.equal(producerMapper.producers.length, 1)
        assert.equal(producerMapper.subscriptionKeyToProducerMap[KEY], DummyProducer2)
        assert.equal(producerMapper.subscriptionKeyToProducerMap[KEY2], DummyProducer2)
        sinon.assert.calledOnce(buildMap)
