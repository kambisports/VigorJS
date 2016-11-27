import _ from 'underscore';
import Events from 'backbone';
import EventKeys from './EventKeys';

class EventRegistry {}

_.extend(EventRegistry.prototype, Events);

// A global EventBus for the entire application
//
// @example How to subscribe to events
//   EventBus.subscribe EventKeys.EXAMPLE_EVENT_KEY, (event) ->
//      # do something with `event` here...
//
class EventBus {

  // Bind a `callback` function to an event key. Passing `all` as key will
  // bind the callback to all events fired.
  //
  // @param [String] the event key to subscribe to. See datacommunication/EventKeys for available keys.
  // @param [function] the callback that receives the event when it is sent
  subscribe(key, callback) {
    if (!this._eventKeyExists(key)) {
      throw `key '${key}' does not exist in EventKeys`;
    }

    if ('function' !== typeof callback) {
      throw 'callback is not a function';
    }

    return this.eventRegistry.on(key, callback);
  }

  // Bind a callback to only be triggered a single time.
  // After the first time the callback is invoked, it will be removed.
  //
  // @param [String] the event key to subscribe to. See datacommunication/EventKeys for available keys.
  // @param [function] the callback that receives the single event when it is sent
  subscribeOnce(key, callback) {
    if (!this._eventKeyExists(key)) {
      throw `key '${key}' does not exist in EventKeys`;
    }

    if ('function' !== typeof callback) {
      throw 'callback is not a function';
    }

    return this.eventRegistry.once(key, callback);
  }


  // Remove a callback.
  //
  // @param [String] the event key to unsubscribe from.
  // @param [Function] the callback that is to be unsubscribed
  unsubscribe(key, callback) {
    if (!this._eventKeyExists(key)) {
      throw `key '${key}' does not exist in EventKeys`;
    }

    if ('function' !== typeof callback) {
      throw 'callback is not a function';
    }

    return this.eventRegistry.off(key, callback);
  }

  // Send an event message  to all bound callbacks. Callbacks are passed the
  // message argument, (unless you're listening on `all`, which will
  // cause your callback to receive the true name of the event as the first
  // argument).
  //
  // @param [String] the event key to send the message on.
  // @param [Object] the message to send
  send(key, message) {
    if (!this._eventKeyExists(key)) {
      throw `key '${key}' does not exist in EventKeys`;
    }

    return this.eventRegistry.trigger(key, message);
  }

  _eventKeyExists(key) {
    const keys = [];
    for (let property in EventKeys) {
      if (EventKeys.hasOwnProperty(property)) {
        let value = EventKeys[property];
        keys.push(value);
      }
    }
    return keys.indexOf(key) >= 0;
  }
}

EventBus.prototype.eventRegistry = new EventRegistry();

export default new EventBus();
