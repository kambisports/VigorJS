Vigor = require '../../../../dist/backbone.vigor'
assert = require 'assert'
sinon = require 'sinon'
# sandbox = undefined

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
  SUBSCRIPTION_KEYS: [KEY1, KEY2]
  subscribe: sinon.spy()
  subscribeToRepositories: sinon.spy()
  unsubscribeFromRepositories: sinon.spy()

describe 'A Producer', ->
  it 'creates subscriptionKeyToComponents for each key', ->
    producer = new DummyProducer()

    _.each producer.SUBSCRIPTION_KEYS, (subscriptionKey) ->
      componentsMap = producer.subscriptionKeyToComponents[subscriptionKey.key]
      assert.equal typeof componentsMap, 'object'
      assert.equal Object.keys(componentsMap).length, 0

  it 'adds a component', ->
    producer = new DummyProducer()
    componentIdentifier = new Vigor.ComponentIdentifier 'foo', sinon.spy(), {}

    producer.addComponent KEY1, componentIdentifier

    componentsForKey = producer.subscriptionKeyToComponents[KEY1.key]
    assert.equal Object.keys(componentsForKey).length, 1
    assert.equal componentsForKey[componentIdentifier.id], componentIdentifier


  it 'calls subscribeToRepositories when the first component is added', ->
    producer = new DummyProducer()
    producer.subscribeToRepositories = sinon.spy()
    componentIdentifier = new Vigor.ComponentIdentifier 'foo', sinon.spy(), {}

    producer.addComponent KEY1, componentIdentifier

    assert producer.subscribeToRepositories.calledOnce

  it 'does not call subscribeToRepositories when a second component is added', ->
    producer = new DummyProducer()
    producer.subscribeToRepositories = sinon.spy()
    componentIdentifier = new Vigor.ComponentIdentifier 'foo', sinon.spy(), {}
    componentIdentifier2 = new Vigor.ComponentIdentifier 'bar', sinon.spy(), {}

    producer.addComponent KEY1, componentIdentifier
    producer.addComponent KEY1, componentIdentifier2

    assert producer.subscribeToRepositories.calledOnce

  it 'calls unsubscribeFromRepositories when the last component is removed', ->
    producer = new DummyProducer()
    producer.unsubscribeFromRepositories = sinon.spy()

    componentId = 'foo'

    componentIdentifier = new Vigor.ComponentIdentifier componentId, sinon.spy(), {}

    producer.addComponent KEY1, componentIdentifier
    producer.removeComponent KEY1, componentId

    assert producer.unsubscribeFromRepositories.calledOnce

  it 'does not call unsubscribeFromRepositories when there are still components subscribed', ->
    producer = new DummyProducer()
    producer.unsubscribeFromRepositories = sinon.spy()

    componentId = 'foo'
    componentId2 = 'bar'

    componentIdentifier = new Vigor.ComponentIdentifier componentId, sinon.spy(), {}
    componentIdentifier2 = new Vigor.ComponentIdentifier componentId2, sinon.spy(), {}

    producer.addComponent KEY1, componentIdentifier
    producer.addComponent KEY1, componentIdentifier2
    producer.removeComponent KEY1, componentId

    assert producer.unsubscribeFromRepositories.notCalled


  it 'throws an error if the key is not known', ->
    producer = new DummyProducer()

    errorFn = -> producer.addComponent INVALID_SUBSCRIPTION_KEY
    assert.throws (-> errorFn()), /Unknown subscription key: invalid-key, could not add component!/


  it 'removes a component from a key', ->
    producer = new DummyProducer()
    componentIdentifier = new Vigor.ComponentIdentifier 'foo', sinon.spy(), {}

    producer.addComponent KEY1, componentIdentifier
    producer.removeComponent KEY1, componentIdentifier.id

    assert.equal Object.keys(producer.subscriptionKeyToComponents[KEY1.key]).length, 0


  it 'removes a component entirely', ->
    componentId = 'foo'

    producer = new DummyProducer()

    componentIdentifier1 = new Vigor.ComponentIdentifier componentId, sinon.spy(), {}
    componentIdentifier2 = new Vigor.ComponentIdentifier componentId, sinon.spy(), {}

    producer.addComponent KEY1, componentIdentifier1
    producer.addComponent KEY2, componentIdentifier2

    producer.removeComponent componentId

    assert.equal Object.keys(producer.subscriptionKeyToComponents[KEY1.key]).length, 0
    assert.equal Object.keys(producer.subscriptionKeyToComponents[KEY2.key]).length, 0

  it 'does not remove components if they are not added', ->
    producer = new DummyProducer()
    componentIdentifier = new Vigor.ComponentIdentifier 'foo', sinon.spy(), {}

    producer.removeComponent KEY1, componentIdentifier.id
    assert.equal Object.keys(producer.subscriptionKeyToComponents[KEY1.key]).length, 0

  it 'does not remove unrelated components', ->
    producer = new DummyProducer()
    componentIdentifier1 = new Vigor.ComponentIdentifier 'foo', sinon.spy(), {}
    componentIdentifier2 = new Vigor.ComponentIdentifier 'bar', sinon.spy(), {}

    producer.addComponent KEY1, componentIdentifier1
    producer.addComponent KEY1, componentIdentifier2
    producer.removeComponent KEY1, componentIdentifier2.id

    assert.equal Object.keys(producer.subscriptionKeyToComponents[KEY1.key]).length, 1
    assert.equal producer.subscriptionKeyToComponents[KEY1.key][componentIdentifier1.id], componentIdentifier1

  it 'does not remove subscriptions on different keys', ->
    producer = new DummyProducer()
    componentIdentifier = new Vigor.ComponentIdentifier 'foo', sinon.spy(), {}

    producer.addComponent KEY1, componentIdentifier
    producer.addComponent KEY2, componentIdentifier
    producer.removeComponent KEY1, componentIdentifier.id

    assert.equal Object.keys(producer.subscriptionKeyToComponents[KEY1.key]).length, 0
    assert.equal Object.keys(producer.subscriptionKeyToComponents[KEY2.key]).length, 1

  it 'produces data', ->
    producer = new DummyProducer()
    callback = sinon.spy()
    producedData = {}
    componentIdentifier = new Vigor.ComponentIdentifier 'foo', callback, {}

    producer.addComponent KEY1, componentIdentifier

    producer.produce KEY1, producedData

    assert callback.calledOnce
    args = callback.args[0]

    assert.equal args.length, 1
    assert.equal args[0], producedData

  it 'does not produce data on the wrong key', ->
    producer = new DummyProducer()
    callback = sinon.spy()
    producedData = {}
    componentIdentifier = new Vigor.ComponentIdentifier 'foo', callback, {}

    producer.addComponent KEY1, componentIdentifier

    producer.produce KEY2, producedData

    assert callback.notCalled

  it 'does not call filter if the options was empty', ->
    producer = new DummyProducer()
    callback = sinon.spy()
    filter = sinon.spy()
    producedData = {}
    componentIdentifier = new Vigor.ComponentIdentifier 'foo', callback, {}

    producer.addComponent KEY1, componentIdentifier

    producer.produce KEY1, producedData, filter

    assert callback.calledOnce
    args = callback.args[0]

    assert.equal args.length, 1
    assert.equal args[0], producedData
    assert filter.notCalled

  it 'calls filter if the options were not empty', ->
    producer = new DummyProducer()
    callback = sinon.spy()
    filter = sinon.spy()
    options =
      foo: 'bar'

    producedData = {}

    componentIdentifier = new Vigor.ComponentIdentifier 'foo', callback, options

    producer.addComponent KEY1, componentIdentifier

    producer.produce KEY1, producedData, filter

    args = filter.args[0]

    assert filter.calledOnce
    assert.equal args.length, 1
    assert.equal args[0], options


  it 'calls the callback if the filter returns true', ->
    producer = new DummyProducer()
    callback = sinon.spy()
    filter = sinon.spy(-> return true)
    options =
      foo: 'bar'

    producedData = {}
    componentIdentifier = new Vigor.ComponentIdentifier 'foo', callback, options

    producer.addComponent KEY1, componentIdentifier

    producer.produce KEY1, producedData, filter

    args = callback.args[0]

    assert callback.calledOnce
    assert.equal args.length, 1
    assert.equal args[0], producedData

  it 'does not call the callback if the filter returns false', ->
    producer = new DummyProducer()
    callback = sinon.spy()
    filter = sinon.spy(-> return false)
    options =
      foo: 'bar'

    producedData = {}
    componentIdentifier = new Vigor.ComponentIdentifier 'foo', callback, options

    producer.addComponent KEY1, componentIdentifier
    producer.produce KEY1, producedData, filter

    assert callback.notCalled
