Vigor = require '../../../../dist/vigor'
assert = require 'assert'
sinon = require 'sinon'

KEY =
  key: 'dummy'
  contract:
    key1: 'string'

class DummyRepository extends Vigor.Repository

dummyRepository1 = new DummyRepository()


class DummyProducer extends Vigor.IdProducer
  PRODUCTION_KEY: KEY
  repositories: [dummyRepository1]
  decorators: []

dummyProducer = undefined

describe 'An IdProducer', ->

  beforeEach ->
    dummyProducer = new DummyProducer()


  it 'should subscribe a component', ->
    componentId = 1

    dummyProducer.subscribe
      id: componentId

    assert dummyProducer.hasId componentId


  it 'should throw an error when the id type is wrong', ->
    componentId = 'a string'

    errorFn = -> dummyProducer.subscribe
      id: componentId

    assert.throws errorFn, "expected the subscription key to be a #{dummyProducer.idType} but got a #{typeof componentId}"


  it 'should subscribe a component with the id returned by idForOptions', ->
    componentId = 1
    componentId2 = 2

    sinon.stub dummyProducer, 'idForOptions', -> componentId2

    dummyProducer.subscribe
      id: componentId

    assert dummyProducer.hasId componentId2

  it 'should unsubscribe a component', ->
    componentId = 1

    subscription =
      id: componentId

    dummyProducer.subscribe subscription
    dummyProducer.unsubscribe subscription

    assert !dummyProducer.hasId componentId


  it 'should unsubscribe a component with the id returned by idForOptions', ->
    componentId = 1
    componentId2 = 2

    subscription =
      id: componentId

    sinon.stub dummyProducer, 'idForOptions', -> componentId2

    dummyProducer.subscribe subscription
    dummyProducer.unsubscribe subscription

    assert !dummyProducer.hasId componentId2


  it 'should immediately produce when a component subscribes', ->
    componentId = 1

    sinon.stub dummyProducer, 'produce'

    subscription =
      id: componentId

    dummyProducer.subscribe subscription

    assert dummyProducer.produce.calledOnce
    args = dummyProducer.produce.args[0]
    assert (args.length is 1)
    assert args[0].length is 1
    assert args[0][0] is componentId


  it 'should eventually produce added items', (done) ->
    componentId = 1

    sinon.stub dummyProducer, 'produce'

    subscription =
      id: componentId

    dummyProducer.subscribe subscription

    dummyProducer.produce.restore()

    sinon.stub dummyProducer, 'produce', ->
      assert arguments.length is 1
      assert arguments[0].length is 1
      assert arguments[0][0] is componentId
      done()

    dummyProducer.onDiffInRepository dummyProducer.repositories[0],
      added: [
        id: subscription.id
      ]
      removed: []
      changed: []

  it 'should eventually produce added items on the idForModel', (done) ->
    componentId = 1

    sinon.stub dummyProducer, 'produce'
    (sinon.stub dummyProducer, 'idForModel').returns componentId

    subscription =
      id: componentId

    dummyProducer.subscribe subscription

    dummyProducer.produce.restore()

    sinon.stub dummyProducer, 'produce', ->
      assert arguments[0][0] is componentId
      done()

    dummyProducer.onDiffInRepository dummyProducer.repositories[0],
      added: [
        id: 'foo'
      ]
      removed: []
      changed: []

  it 'should not produce on added items that are not subscribed to', (done) ->
    componentId = 1

    sinon.stub dummyProducer, 'produce', ->
      sinon.assert.fail()

    dummyProducer.onDiffInRepository dummyProducer.repositories[0],
      added: [
        id: componentId
      ]
      removed: []
      changed: []

    setTimeout done, 250

  it 'should allow idForModel to return an array for added items', (done) ->
    componentId1 = 1
    componentId2 = 2

    sinon.stub dummyProducer, 'produce'
    (sinon.stub dummyProducer, 'idForModel').returns [componentId1, componentId2]

    subscription1 =
      id: componentId1

    subscription2 =
      id: componentId2

    dummyProducer.subscribe subscription1
    dummyProducer.subscribe subscription2

    dummyProducer.produce.restore()

    sinon.stub dummyProducer, 'produce', (ids) ->
      assert.deepEqual ids, [componentId1, componentId2]
      done()

    dummyProducer.onDiffInRepository dummyProducer.repositories[0],
      added: [
        id: 'foo'
      ]
      removed: []
      changed: []

  it 'should eventually produce removed items', (done) ->
    componentId = 1

    sinon.stub dummyProducer, 'produce'

    subscription =
      id: componentId

    dummyProducer.subscribe subscription

    dummyProducer.produce.restore()

    sinon.stub dummyProducer, 'produce', ->
      assert arguments[0][0] is componentId
      done()

    dummyProducer.onDiffInRepository dummyProducer.repositories[0],
      added: []
      removed: [
        id: subscription.id
      ]
      changed: []

  it 'should eventually produce removed items on the idForModel', (done) ->
    componentId = 1

    sinon.stub dummyProducer, 'produce'
    (sinon.stub dummyProducer, 'idForModel').returns componentId

    subscription =
      id: componentId

    dummyProducer.subscribe subscription

    dummyProducer.produce.restore()

    sinon.stub dummyProducer, 'produce', ->
      assert arguments[0][0] is componentId
      done()

    dummyProducer.onDiffInRepository dummyProducer.repositories[0],
      added: []
      removed: [
        id: 'foo'
      ]
      changed: []

  it 'should not produce on removed items that are not subscribed to', (done) ->
    componentId = 1

    sinon.stub dummyProducer, 'produce', ->
      sinon.assert.fail()

    dummyProducer.onDiffInRepository dummyProducer.repositories[0],
      added: []
      removed: [
        id: componentId
      ]
      changed: []

    setTimeout done, 250


  it 'should allow idForModel to return an array for removed items', (done) ->
    componentId1 = 1
    componentId2 = 2

    sinon.stub dummyProducer, 'produce'
    (sinon.stub dummyProducer, 'idForModel').returns [componentId1, componentId2]

    subscription1 =
      id: componentId1

    subscription2 =
      id: componentId2

    dummyProducer.subscribe subscription1
    dummyProducer.subscribe subscription2

    dummyProducer.produce.restore()

    sinon.stub dummyProducer, 'produce', (ids) ->
      assert.deepEqual ids, [componentId1, componentId2]
      done()

    dummyProducer.onDiffInRepository dummyProducer.repositories[0],
      added: []
      removed: [
        id: 'foo'
      ]
      changed: []


  it 'should eventually produce changed items', (done) ->
    componentId = 1

    sinon.stub dummyProducer, 'produce'

    subscription =
      id: componentId

    dummyProducer.subscribe subscription

    dummyProducer.produce.restore()

    sinon.stub dummyProducer, 'produce', ->
      assert arguments[0][0] is componentId
      done()

    dummyProducer.onDiffInRepository dummyProducer.repositories[0],
      added: []
      removed: []
      changed: [
        id: subscription.id
      ]

  it 'should eventually produce changed items on the idForModel', (done) ->
    componentId = 1

    sinon.stub dummyProducer, 'produce'
    (sinon.stub dummyProducer, 'idForModel').returns componentId

    subscription =
      id: componentId

    dummyProducer.subscribe subscription

    dummyProducer.produce.restore()

    sinon.stub dummyProducer, 'produce', ->
      assert arguments[0][0] is componentId
      done()

    dummyProducer.onDiffInRepository dummyProducer.repositories[0],
      added: []
      removed: []
      changed: [
        id: 'foo'
      ]

  it 'should not produce on added items that are not subscribed to', (done) ->
    componentId = 1

    sinon.stub dummyProducer, 'produce', ->
      sinon.assert.fail()

    dummyProducer.onDiffInRepository dummyProducer.repositories[0],
      added: []
      removed: []
      changed: [
        id: componentId
      ]

    setTimeout done, 250


  it 'should allow idForModel to return an array for removed items', (done) ->
    componentId1 = 1
    componentId2 = 2

    sinon.stub dummyProducer, 'produce'
    (sinon.stub dummyProducer, 'idForModel').returns [componentId1, componentId2]

    subscription1 =
      id: componentId1

    subscription2 =
      id: componentId2

    dummyProducer.subscribe subscription1
    dummyProducer.subscribe subscription2

    dummyProducer.produce.restore()

    sinon.stub dummyProducer, 'produce', (ids) ->
      assert.deepEqual ids, [componentId1, componentId2]
      done()

    dummyProducer.onDiffInRepository dummyProducer.repositories[0],
      added: []
      removed: []
      changed: [
        id: 'foo'
      ]


  it 'should eventually produce on ids that were changed if shouldPropagateModelChange is true', (done) ->
    componentId = 1

    sinon.stub dummyProducer, 'produce'
    sinon.stub dummyProducer, 'shouldPropagateModelChange', -> true

    subscription =
      id: componentId

    dummyProducer.subscribe subscription

    dummyProducer.produce.restore()

    sinon.stub dummyProducer, 'produce', ->
      assert arguments[0][0] is componentId
      done()

    dummyProducer.onDiffInRepository dummyProducer.repositories[0],
      added: []
      removed: []
      changed: [
        id: subscription.id
      ]


  it 'should not produce on added items that are not subscribed to', (done) ->
    componentId = 1

    sinon.stub dummyProducer, 'produce'

    sinon.stub dummyProducer, 'shouldPropagateModelChange', -> false

    subscription =
      id: componentId

    dummyProducer.subscribe subscription

    dummyProducer.produce.restore()

    sinon.stub dummyProducer, 'produce', ->
      sinon.assert.fail()

    dummyProducer.onDiffInRepository dummyProducer.repositories[0],
      added: []
      removed: []
      changed: [
        id: componentId
      ]

    setTimeout done, 250


  it 'should eventually update given ids', (done) ->
    componentId = 1

    sinon.stub dummyProducer, 'produce'

    subscription =
      id: componentId

    dummyProducer.subscribe subscription

    dummyProducer.produce.restore()

    sinon.stub dummyProducer, 'produce', ->
      assert arguments[0][0] is componentId
      done()

    dummyProducer.produceDataForIds [subscription.id]

  it 'should eventually produce for all ids', (done) ->
    componentId = 1

    sinon.stub dummyProducer, 'produce'

    subscription =
      id: componentId

    dummyProducer.subscribe subscription

    dummyProducer.produce.restore()

    sinon.stub dummyProducer, 'produce', ->
      assert arguments[0][0] is componentId
      done()

    dummyProducer.produceDataForIds()


  it 'should eventually produce for all ids when id type is string', (done) ->
    componentId = 'hello'

    dummyProducer.idType = 'string'
    sinon.stub dummyProducer, 'produce'

    subscription =
      id: componentId

    dummyProducer.subscribe subscription

    dummyProducer.produce.restore()

    sinon.stub dummyProducer, 'produce', ->
      assert arguments[0][0] is componentId
      done()

    dummyProducer.produceDataForIds()

  it 'calls currentData when producing data and add the passed id to the data returned', ->
    passedId = 1
    expectedResult = { id: 1 }

    sinon.stub dummyProducer, 'produce'

    subscription =
      id: passedId

    component =
      options: subscription
      callback: sinon.spy()

    dummyProducer.addComponent component

    dummyProducer.produce.restore()

    sinon.stub dummyProducer, 'currentData', (id) ->
      assert id is passedId
      return {}

    dummyProducer.produce dummyProducer.allIds()

    assert component.callback.calledOnce
    assert component.callback.args.length is 1
    assert component.callback.args[0].length is 1
    assert.deepEqual component.callback.args[0][0], expectedResult

  it 'if currentData doesnt return any data and empty object should be used', ->
    passedId = 1
    expectedResult = { id: 1 }

    sinon.stub dummyProducer, 'produce'

    subscription =
      id: passedId

    component =
      options: subscription
      callback: sinon.spy()

    dummyProducer.addComponent component

    dummyProducer.produce.restore()

    sinon.stub dummyProducer, 'currentData', (id) ->
      assert id is passedId
      return undefined

    dummyProducer.produce dummyProducer.allIds()

    assert component.callback.calledOnce
    assert component.callback.args.length is 1
    assert component.callback.args[0].length is 1
    assert.deepEqual component.callback.args[0][0], expectedResult

  it 'passes along data from currentData to decorate to allow gathered data to be decorated', ->
    passedId = 1
    expectedResult = {
      id: 1
      val: 2
      decoratedVal: 3
    }

    sinon.stub dummyProducer, 'produce'

    subscription =
      id: passedId

    component =
      options: subscription
      callback: sinon.spy()

    dummyProducer.addComponent component

    dummyProducer.produce.restore()

    sinon.stub dummyProducer, 'currentData', (id) ->
      assert id is passedId
      obj =
        val: 2
      return obj

    decorator1 = sinon.spy (data) ->
      data.decoratedVal = 3

    dummyProducer.decorators = [decorator1]

    dummyProducer.produce dummyProducer.allIds()

    assert component.callback.calledOnce
    assert component.callback.args.length is 1
    assert component.callback.args[0].length is 1
    assert.deepEqual component.callback.args[0][0], expectedResult

  it 'calls decorate when producing data', ->
    componentId = 1
    decoratedData = {}

    sinon.stub dummyProducer, 'produce'

    subscription =
      id: componentId

    component =
      options: subscription
      callback: sinon.spy()

    dummyProducer.addComponent component

    dummyProducer.produce.restore()
    sinon.stub dummyProducer, 'decorate', (data) ->
      assert data.id is componentId
      decoratedData

    dummyProducer.produce dummyProducer.allIds()
    assert component.callback.calledOnce
    assert component.callback.args.length is 1
    assert component.callback.args[0].length is 1
    assert component.callback.args[0][0] is decoratedData


  it 'passes data through decorators in order before producing', ->
    componentId = 1
    decoratedData = {}

    sinon.stub dummyProducer, 'produce'

    component =
      options:
        id: componentId
      callback: sinon.spy()

    dummyProducer.addComponent component
    dummyProducer.produce.restore()

    decorator1 = sinon.spy (data) ->
      data.decorator1 = true

    decorator2 = sinon.spy (data) ->
      assert.equal data.decorator1, true
      data.decorator2 = true

    dummyProducer.decorators = [decorator1, decorator2]

    dummyProducer.produce dummyProducer.allIds()

    assert decorator1.calledOnce
    assert decorator2.calledOnce

    assert component.callback.calledOnce
    assert component.callback.args.length is 1
    assert component.callback.args[0].length is 1
    assert component.callback.args[0][0].decorator1
    assert component.callback.args[0][0].decorator2

  it 'filters produced data to the component with the correct id', ->
    componentId1 = 1
    componentId2 = 2
    optionsId1 = 3
    optionsId2 = 4

    sinon.stub dummyProducer, 'produce'

    component1 =
      id: componentId1
      options:
        id: optionsId1
      callback: sinon.spy()

    component2 =
      id: componentId2
      options:
        id: optionsId2
      callback: sinon.spy()

    dummyProducer.addComponent component1
    dummyProducer.addComponent component2
    dummyProducer.produce.restore()

    dummyProducer.produce dummyProducer.allIds()

    assert component1.callback.args.length is 1
    assert component1.callback.args[0].length is 1
    assert component1.callback.args[0][0].id is optionsId1

    assert component2.callback.args.length is 1
    assert component2.callback.args[0].length is 1
    assert component2.callback.args[0][0].id is optionsId2

  it 'should produce data to all components subscribed to the same options id', ->
    componentId1 = 1
    componentId2 = 2
    optionsId = 1

    sinon.stub dummyProducer, 'produce'

    component1 =
      id: componentId1
      options:
        id: optionsId
      callback: sinon.spy()

    component2 =
      id: componentId2
      options:
        id: optionsId
      callback: sinon.spy()

    dummyProducer.addComponent component1
    dummyProducer.addComponent component2
    dummyProducer.produce.restore()

    dummyProducer.produce dummyProducer.allIds()
    assert component1.callback.args.length is 1
    assert component1.callback.args[0].length is 1
    assert component1.callback.args[0][0].id is optionsId

    assert component2.callback.args.length is 1
    assert component2.callback.args[0].length is 1
    assert component2.callback.args[0][0].id is optionsId


  it 'should not produce data to a component after it has been removed', ->
    componentId = 1
    optionsId = 1

    sinon.stub dummyProducer, 'produce'

    component =
      id: componentId
      options:
        id: optionsId
      callback: sinon.spy()

    dummyProducer.addComponent component
    dummyProducer.removeComponent component.id
    dummyProducer.produce.restore()

    dummyProducer.produce dummyProducer.allIds()
    assert component.callback.args.length is 0


  it 'should continue to produce data to component after another component with the same options id is removed', ->
    componentId1 = 1
    componentId2 = 2
    optionsId = 1

    sinon.stub dummyProducer, 'produce'

    component1 =
      id: componentId1
      options:
        id: optionsId
      callback: sinon.spy()

    component2 =
      id: componentId2
      options:
        id: optionsId
      callback: sinon.spy()

    dummyProducer.addComponent component1
    dummyProducer.addComponent component2
    dummyProducer.removeComponent component1.id
    dummyProducer.produce.restore()

    dummyProducer.produce dummyProducer.allIds()
    assert component1.callback.args.length is 0
    assert component2.callback.args.length is 1
