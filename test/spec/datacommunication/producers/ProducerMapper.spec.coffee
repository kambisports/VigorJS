Vigor = require '../../../../dist/backbone.vigor'
assert = require 'assert'
sinon = require 'sinon'

producerMapper = Vigor.ProducerMapper

KEY =
  key: 'dummy'
  contract:
    val1: true
    val2: undefined

KEY2 =
  key: 'dummy2'
  contract:
    val1: 'string'

class DummyProducer extends Vigor.Producer
  subscribe: ->
  dispose: ->
  subscribeToRepositories: ->
  SUBSCRIPTION_KEYS: [KEY]

class DummyProducer2 extends Vigor.Producer
  subscribe: ->
  dispose: ->
  subscribeToRepositories: ->
  SUBSCRIPTION_KEYS: [KEY, KEY2]

describe 'A ProducerMapper', ->

  afterEach ->
    do producerMapper.reset

  describe 'given a registered subscription key', ->
    it 'it should return a producerClass', ->
      producerMapper.register DummyProducer
      producer = producerMapper.producerClassForKey KEY
      assert.equal producer, DummyProducer

    it 'it should return a producer', ->
      producerMapper.register DummyProducer
      producer = producerMapper.producerForKey KEY
      assert producer instanceof DummyProducer

  describe 'given a unregistered subscription key', ->
    it 'it should throw a "No producer found for subscription" error', ->
      producerMapper.register DummyProducer

  describe 'when trying to find a producer when no producers are registered', ->
    it 'it should throw a "There are No producers registered" error', ->
      errorFn = -> producerMapper.producerClassForKey KEY
      assert.throws (-> errorFn()), /There are no producers registered - register producers through the DataCommunicationManager/
