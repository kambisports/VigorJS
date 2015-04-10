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
  key: 'myyud'
  contract:
    val1: true
    val2: undefined


class DummyProducer extends Vigor.Producer
  subscribe: ->
  dispose: ->
  subscribeToRepositories: ->
  PRODUCTION_KEY: KEY


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
      errorFn = -> producerMapper.producerForKey KEY2
      assert.throws (-> errorFn()), "No producer found for subscription #{KEY2.key}"

  describe 'when trying to find a producer when no producers are registered', ->
    it 'it should throw a "There are No producers registered" error', ->
      errorFn = -> producerMapper.producerClassForKey KEY
      assert.throws (-> errorFn()), /There are no producers registered - register producers through the DataCommunicationManager/

  describe 'when trying to register a producer with an existing key', ->
    it 'should throw an "already registered" error', ->
      errorFn = -> producerMapper.register Object.create { PRODUCTION_KEY: KEY }
      assert.throws (-> errorFn()), "A producer for the key #{KEY} is already registered"


  describe 'reset', ->
    it 'should reset the mapper', ->
      producerMapper.register DummyProducer
      producerMapper.reset()
      assert.equal producerMapper.producers.length, 0

      errorFn = -> producerMapper.producerClassForKey DummyProducer::PRODUCTION_KEY
      assert.throws (-> errorFn()), "No producer found for subscription #{DummyProducer::PRODUCTION_KEY.key}"
