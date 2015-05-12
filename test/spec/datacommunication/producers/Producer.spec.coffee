Vigor = require '../../../../dist/vigor'
assert = require 'assert'
sinon = require 'sinon'

KEY1 =
  key: 'dummy'
  contract:
    key1: 'string'

KEY2 =
  key: 'ymmud'
  contract:
    key1: 'string'

INVALID_SUBSCRIPTION_KEY =
  key: 'invalid-key'
  contract:
    key1: 'string'


class DummyProducer extends Vigor.Producer
  PRODUCTION_KEY: KEY1

class DummyRepository extends Vigor.Repository

describe 'A Producer', ->

  it 'adds a component', ->
    producer = new DummyProducer()
    componentIdentifier = new Vigor.Subscription 'foo', sinon.spy(), {}

    producer.addComponent componentIdentifier

    componentsForKey = producer.registeredComponents
    assert.equal Object.keys(componentsForKey).length, 1
    assert.equal componentsForKey[componentIdentifier.id], componentIdentifier


  it 'ignores calls to add a component more than once', ->
    producer = new DummyProducer()
    componentIdentifier = new Vigor.Subscription 'foo', sinon.spy(), {}

    producer.addComponent componentIdentifier
    producer.addComponent componentIdentifier

    componentsForKey = producer.registeredComponents
    assert.equal Object.keys(componentsForKey).length, 1
    assert.equal componentsForKey[componentIdentifier.id], componentIdentifier


  it 'calls subscribeToRepositories when the first component is added', ->
    producer = new DummyProducer()

    producer.subscribeToRepositories = sinon.spy()
    componentIdentifier = new Vigor.Subscription 'foo', sinon.spy(), {}

    producer.addComponent componentIdentifier

    assert producer.subscribeToRepositories.calledOnce


  it 'subscribes to repositories', ->
    producer = new DummyProducer()
    producer.onDiffInRepository = sinon.spy()
    dummyRepository = new DummyRepository()
    producer.repositories = [
      dummyRepository
    ]

    data = {}

    producer.subscribeToRepositories()
    dummyRepository.trigger Vigor.Repository::REPOSITORY_DIFF, data

    assert producer.onDiffInRepository.calledOnce


  it 'subscribes to repositories with custom callbacks', ->
    producer = new DummyProducer()
    producer.dummyRepositoryCallback = sinon.spy()
    dummyRepository = new DummyRepository()
    producer.repositories = [
      {
        repository: dummyRepository,
        callback: 'dummyRepositoryCallback'
      }
    ]

    data = {}

    producer.subscribeToRepositories()
    dummyRepository.trigger Vigor.Repository::REPOSITORY_DIFF, data

    assert producer.dummyRepositoryCallback.calledOnce


  it 'throws an error on unexpected format of producer repositories definitions', ->
    producer = new DummyProducer()
    producer.repositories = [
      {
        repo: 'foo',
        call: 'dummyRepositoryCallback'
      }
    ]

    errorFn = -> producer.subscribeToRepositories()
    assert.throws (-> errorFn()), "unexpected format of producer repositories definition"

  it 'does not call subscribeToRepositories when a second component is added', ->
    producer = new DummyProducer()
    producer.subscribeToRepositories = sinon.spy()
    componentIdentifier = new Vigor.Subscription 'foo', sinon.spy(), {}
    componentIdentifier2 = new Vigor.Subscription 'bar', sinon.spy(), {}

    producer.addComponent componentIdentifier
    producer.addComponent componentIdentifier2

    assert producer.subscribeToRepositories.calledOnce


  it 'calls unsubscribeFromRepositories when the last component is removed', ->
    producer = new DummyProducer()
    producer.unsubscribeFromRepositories = sinon.spy()

    componentId = 'foo'

    componentIdentifier = new Vigor.Subscription componentId, sinon.spy(), {}

    producer.addComponent componentIdentifier
    producer.removeComponent componentId

    assert producer.unsubscribeFromRepositories.calledOnce


  it 'does not call unsubscribeFromRepositories when there are still components subscribed', ->
    producer = new DummyProducer()
    producer.unsubscribeFromRepositories = sinon.spy()

    componentId = 'foo'
    componentId2 = 'bar'

    componentIdentifier = new Vigor.Subscription componentId, sinon.spy(), {}
    componentIdentifier2 = new Vigor.Subscription componentId2, sinon.spy(), {}

    producer.addComponent componentIdentifier
    producer.addComponent componentIdentifier2
    producer.removeComponent componentId

    assert producer.unsubscribeFromRepositories.notCalled


  it 'unsubscribes from repositories', ->
    producer = new DummyProducer()
    producer.onDiffInRepository = sinon.spy()
    producer.dummyRepositoryCallback = sinon.spy()
    dummyRepository = new DummyRepository()
    dummyRepository2 = new DummyRepository()

    producer.repositories = [
      dummyRepository
    ]

    data = {}

    producer.subscribeToRepositories()
    producer.unsubscribeFromRepositories()

    dummyRepository.trigger Vigor.Repository::REPOSITORY_DIFF, data

    assert producer.onDiffInRepository.notCalled


  it 'unsubscribes from repositories with custom callbacks', ->
    producer = new DummyProducer()
    producer.onDiffInRepository = sinon.spy()
    producer.dummyRepositoryCallback = sinon.spy()
    dummyRepository = new DummyRepository()
    producer.repositories = [
      {
        repository: dummyRepository,
        callback: 'dummyRepositoryCallback'
      }
    ]

    data = {}

    producer.subscribeToRepositories()
    producer.unsubscribeFromRepositories()
    dummyRepository.trigger Vigor.Repository::REPOSITORY_DIFF, data

    assert producer.onDiffInRepository.notCalled
    assert producer.dummyRepositoryCallback.notCalled


  it 'produces data on repository diff', ->
    producer = new DummyProducer()
    producer.produceData = sinon.spy()

    producer.onDiffInRepository()

    assert producer.produceData.calledOnce

  it 'removes a component', ->
    producer = new DummyProducer()
    componentIdentifier = new Vigor.Subscription 'foo', sinon.spy(), {}

    producer.addComponent componentIdentifier
    producer.removeComponent componentIdentifier.id

    assert.equal Object.keys(producer.registeredComponents).length, 0


  it 'does not remove components if they are not added', ->
    producer = new DummyProducer()
    componentIdentifier = new Vigor.Subscription 'foo', sinon.spy(), {}

    producer.removeComponent componentIdentifier.id
    assert.equal Object.keys(producer.registeredComponents).length, 0


  it 'does not remove unrelated components', ->
    producer = new DummyProducer()
    componentIdentifier1 = new Vigor.Subscription 'foo', sinon.spy(), {}
    componentIdentifier2 = new Vigor.Subscription 'bar', sinon.spy(), {}

    producer.addComponent componentIdentifier1
    producer.addComponent componentIdentifier2
    producer.removeComponent componentIdentifier2.id

    assert.equal Object.keys(producer.registeredComponents).length, 1
    assert.equal producer.registeredComponents[componentIdentifier1.id], componentIdentifier1


  it 'produces data', ->
    producer = new DummyProducer()
    callback = sinon.spy()
    producedData = {}
    componentIdentifier = new Vigor.Subscription 'foo', callback, {}

    data = { key1: '' }
    currentData = sinon.stub(producer, "currentData", -> data)
    producer.addComponent componentIdentifier

    assert callback.calledOnce

    args = callback.args[0]
    assert.equal args.length, 1
    assert.equal args[0], data

  it 'calls decorate when producing data', ->
    producer = new DummyProducer()

    originalData = {}
    decoratedData = {}

    sinon.stub producer, 'decorate', (data) ->
      assert.equal data, originalData
      decoratedData

    producer.produce originalData
    assert producer.decorate.calledOnce

  it 'calls the callback with the decorated data', ->
    producer = new DummyProducer()

    decoratedData = {}

    callback = sinon.spy()
    componentIdentifier = new Vigor.Subscription 'foo', callback, {}

    sinon.stub producer, 'decorate', (data) ->
      decoratedData

    producer.addComponent componentIdentifier

    assert callback.calledOnce
    assert callback.calledWith decoratedData

  it 'passes the data through the decorators in order', ->
    originalData = {}

    decorator1 = sinon.spy (data) ->
      assert.equal data, originalData
      data.decorator1 = true

    decorator2 = sinon.spy (data) ->
      assert.equal data.decorator1, true
      data.decorator2 = true

    producer = new DummyProducer()
    producer.decorators = [decorator1, decorator2]

    currentData = sinon.stub producer, "currentData", -> originalData

    callback = sinon.spy()
    componentIdentifier = new Vigor.Subscription 'foo', callback, {}

    producer.addComponent componentIdentifier

    assert decorator1.calledOnce
    assert decorator2.calledOnce
    assert callback.calledOnce
    args = callback.args[0]
    assert.equal args.length, 1
    data = args[0]
    assert.equal data.decorator2, true

  it 'throws an error if the subscription key does not have a contract', ->
    producer = new DummyProducer()
    producer.PRODUCTION_KEY =
      key: producer.PRODUCTION_KEY.key

    errorFn = ->
      producer.produce {}

    assert.throws errorFn, "The subscriptionKey #{producer.PRODUCTION_KEY.key} doesn't have a contract specified"
