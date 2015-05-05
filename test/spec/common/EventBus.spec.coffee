Vigor = require '../../../dist/vigor'
assert = require 'assert'
sinon = require 'sinon'

EventBus = Vigor.EventBus

testEvent1 =
  someProp: 'someValue1'

testEvent2 =
  someProp: 'someValue2'

EventKeys = Vigor.EventKeys.extend
  ADD_OUTCOMES_TO_BETSLIP_REQUESTED: 'add_outcomes_to_betslip_requested'
  BET_PLACED: 'bet_placed'

callbacks = {}

describe 'An eventbus', ->
  beforeEach ->
    callbacks.subscriber1 = sinon.spy()
    callbacks.subscriber2 = sinon.spy()
    callbacks.subscriberOnce = sinon.spy()
    callbacks.subscriberToAll = sinon.spy()

  it 'should subscribe a callback to an event key that exists', ->
    EventBus.subscribe EventKeys.ADD_OUTCOMES_TO_BETSLIP_REQUESTED, ->


  it 'should not subscribe a callback to an event key that does not exists', ->
    errorFn = -> EventBus.subscribe('none-existing-event-key', ->)
    assert.throws (-> errorFn()), /key 'none-existing-event-key' does not exist in EventKeys/


  it 'should not subscribe a callback that is not a function', ->
    errorFn = -> EventBus.subscribe EventKeys.ADD_OUTCOMES_TO_BETSLIP_REQUESTED, null
    assert.throws (-> errorFn()), /callback is not a function/

    errorFn = -> EventBus.subscribe EventKeys.ADD_OUTCOMES_TO_BETSLIP_REQUESTED, 4711
    assert.throws (-> errorFn()), /callback is not a function/


  it 'should not send an event if the key does not exist', ->
    errorFn = -> EventBus.send 'none-existing-event-key', testEvent1
    assert.throws (-> errorFn()), /key 'none-existing-event-key' does not exist in EventKeys/


  it 'should deliver an event to all subscribers for a certain key', ->
    EventBus.subscribe EventKeys.BET_PLACED, callbacks.subscriber1
    EventBus.subscribe EventKeys.BET_PLACED, callbacks.subscriber2

    EventBus.send EventKeys.BET_PLACED, testEvent1
    EventBus.send EventKeys.BET_PLACED, testEvent2

    assert(callbacks.subscriber1.calledWith(testEvent1))
    assert(callbacks.subscriber2.calledWith(testEvent1))

    assert(callbacks.subscriber1.calledWith(testEvent2))
    assert(callbacks.subscriber2.calledWith(testEvent2))


  it 'should deliver all events to a subscriber that has subscribed to the special `all` key', ->
    EventBus.subscribe EventKeys.ALL_EVENTS, callbacks.subscriber1

    EventBus.send EventKeys.ADD_OUTCOMES_TO_BETSLIP_REQUESTED, testEvent1
    EventBus.send EventKeys.BET_PLACED, testEvent2

    assert(callbacks.subscriber1.calledWith(EventKeys.ADD_OUTCOMES_TO_BETSLIP_REQUESTED, testEvent1))
    assert(callbacks.subscriber1.calledWith(EventKeys.BET_PLACED, testEvent2))


  it 'should not deliver an event to a subscriber of another key', ->
    EventBus.subscribe EventKeys.BET_PLACED, callbacks.subscriber1
    EventBus.send EventKeys.ADD_OUTCOMES_TO_BETSLIP_REQUESTED, testEvent1

    assert.equal(callbacks.subscriber1.callCount, 0)


  it 'should only deliver ONE event per subscribed key to a subscriber that used `subscribeOnce`', ->
    EventBus.subscribeOnce EventKeys.BET_PLACED, callbacks.subscriber1

    EventBus.send EventKeys.BET_PLACED, testEvent2
    EventBus.send EventKeys.BET_PLACED, testEvent1

    assert(callbacks.subscriber1.calledWith(testEvent2))
    assert.equal(callbacks.subscriber1.callCount, 1)


  it 'should not deliver an event to a subscriber that has unsubscribed from a key', ->
    EventBus.subscribe EventKeys.BET_PLACED, callbacks.subscriber1
    EventBus.send EventKeys.BET_PLACED, testEvent1

    assert.equal(callbacks.subscriber1.callCount, 1)

    EventBus.unsubscribe EventKeys.BET_PLACED, callbacks.subscriber1
    EventBus.send EventKeys.BET_PLACED, testEvent2

    assert.equal(callbacks.subscriber1.callCount, 1)
