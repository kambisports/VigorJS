assert = require 'assert'

EventKeys = Vigor.EventKeys #require 'datacommunication/EventKeys'
EventBus = Vigor.EventBus

testEvent1 =
  someProp: 'someValue'

testEvent2 =
  someProp: 'someValue'

callbacks =
  subscriber1: ->
  subscriber2: ->
  subscriberOnce: ->
  subscriberToAll: ->

describe 'An eventbus', ->
  beforeEach ->

    spyOn callbacks, 'subscriber1'
    spyOn callbacks, 'subscriber2'
    spyOn callbacks, 'subscriberOnce'
    spyOn callbacks, 'subscriberToAll'

    do callbacks.subscriber1.reset
    do callbacks.subscriber2.reset
    do callbacks.subscriberOnce.reset
    do callbacks.subscriberToAll.reset


  it 'should subscribe a callback to an event key that exists', ->
    EventBus.subscribe EventKeys.ADD_OUTCOMES_TO_BETSLIP_REQUESTED, ->


  it 'should not subscribe a callback to an event key that does not exists', ->
    expect( ->
      EventBus.subscribe 'none-existing-event-key', ->
    ).toThrow new Error("key 'none-existing-event-key' does not exist in EventKeys")


  it 'should not subscribe a callback that is not a function', ->
    expect( ->
      EventBus.subscribe EventKeys.ADD_OUTCOMES_TO_BETSLIP_REQUESTED, null
    ).toThrow new Error('callback is not a function')

    expect( ->
      EventBus.subscribe EventKeys.ADD_OUTCOMES_TO_BETSLIP_REQUESTED, 4711
    ).toThrow new Error('callback is not a function')


  it 'should not send an event if the key does not exist', ->
    expect( ->
      EventBus.send 'none-existing-event-key', testEvent1
    ).toThrow new Error("key 'none-existing-event-key' does not exist in EventKeys")


  it 'should deliver an event to all subscribers for a certain key', ->
    EventBus.subscribe EventKeys.BET_PLACED, callbacks.subscriber1
    EventBus.subscribe EventKeys.BET_PLACED, callbacks.subscriber2

    EventBus.send EventKeys.BET_PLACED, testEvent1
    EventBus.send EventKeys.BET_PLACED, testEvent2

    expect(callbacks.subscriber1).toHaveBeenCalledWith(testEvent1)
    expect(callbacks.subscriber2).toHaveBeenCalledWith(testEvent1)

    expect(callbacks.subscriber1).toHaveBeenCalledWith(testEvent2)
    expect(callbacks.subscriber2).toHaveBeenCalledWith(testEvent2)


  it 'should deliver all events to a subscriber that has subscribed to the special `all` key', ->
    EventBus.subscribe EventKeys.ALL_EVENTS, callbacks.subscriber1

    EventBus.send EventKeys.ADD_OUTCOMES_TO_BETSLIP_REQUESTED, testEvent1
    EventBus.send EventKeys.BET_PLACED, testEvent2

    expect(callbacks.subscriber1).toHaveBeenCalledWith(EventKeys.ADD_OUTCOMES_TO_BETSLIP_REQUESTED, testEvent1)
    expect(callbacks.subscriber1).toHaveBeenCalledWith(EventKeys.BET_PLACED, testEvent2)


  it 'should not deliver an event to a subscriber of another key', ->
    EventBus.subscribe EventKeys.BET_PLACED, callbacks.subscriber1

    EventBus.send EventKeys.ADD_OUTCOMES_TO_BETSLIP_REQUESTED, testEvent1
    expect(callbacks.subscriber1.calls.length).toEqual 0


  it 'should only deliver ONE event per subscribed key to a subscriber that used `subscribeOnce`', ->
    EventBus.subscribeOnce EventKeys.BET_PLACED, callbacks.subscriber1

    EventBus.send EventKeys.BET_PLACED, testEvent2
    EventBus.send EventKeys.BET_PLACED, testEvent1

    expect(callbacks.subscriber1).toHaveBeenCalledWith(testEvent2)
    expect(callbacks.subscriber1.calls.length).toEqual 1


  it 'should not deliver an event to a subscriber that has unsubscribed from a key', ->
    EventBus.subscribe EventKeys.BET_PLACED, callbacks.subscriber1
    EventBus.send EventKeys.BET_PLACED, testEvent1

    expect(callbacks.subscriber1.calls.length).toEqual 1

    EventBus.unsubscribe EventKeys.BET_PLACED, callbacks.subscriber1

    EventBus.send EventKeys.BET_PLACED, testEvent2

    expect(callbacks.subscriber1.calls.length).toEqual 1