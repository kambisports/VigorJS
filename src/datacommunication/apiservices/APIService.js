import _ from 'underscore';
import {Model, Events} from 'backbone';
// ## ServiceChannel
// The ServiceChannel class is private to the APIService class. Service channels are used to group subscriptions to an
// API service into sets of subscriptions whose requirements can be fulfilled with a single request, thus reducing
// network usage.<br/>
// Each subscription to the channel may have a polling interval, and the channel will ask the service that created
// it to perform a fetch when the polling intervals elapse.<br/>
// Service channels are not used for post requests, which are always started immediately, idependent of other requests,
// and cannot be polled.
class ServiceChannel {

  // If subscribers are provided, the requests will start immediately.
  constructor(_window, name, service, subscribers) {
    this._window = _window;
    this.service = service;

    // The name of this channel; used by the API service to uniquely identify it.
    this.name = name;

    // An array of subscription objects, each of which may contain a pollingInterval in ms, and a params object
    this.subscribers = subscribers;

    // The minimum polling interval of the subscribers, or 0
    this.pollingInterval = undefined;

    // The unix timestamp of the last poll
    this.lastPollTime = undefined;

    // A timeout id, as returned by window.setTimeout, for the next poll.
    this.timeout = undefined;

    this.params = this.getParams();

    this.restart();
  }


  // **restart**<br/>
  // Restarts the channel, causing it to schedule the next request.<br/>
  // This method can be called at any time, since it takes into account the time since the last request.
  restart() {
    let wait;
    this.pollingInterval = this.getPollingInterval();
    if (this.lastPollTime != null) {
      const elapsedWait = this._window.Date.now() - this.lastPollTime;
      wait = Math.max(this.pollingInterval - elapsedWait, 0);
    } else {
      wait = 0;
    }
    this.setupNextFetch(wait);
  }

  // **stop**<br/>
  // Stops the channel and asks the service to remove it.
  stop() {
    this._window.clearTimeout(this.timeout);
    this.timeout = undefined;
    this.subscribers = undefined;
    this.params = undefined;
    this.service.removeChannel(this);
  }

  // **setupNextFetch**<br/>
  // @param [wait]: Number<br/>
  // The amount of time to wait until the fetch. Defaults to the current polling interval.
  //
  // Schedules the next fetch to start the given number of ms in the future.
  setupNextFetch(wait = this.pollingInterval) {
    this._window.clearTimeout(this.timeout);

    this.timeout = this._window.setTimeout(() => {
      this.lastPollTime = this._window.Date.now();
      this.service.fetch(this.params);
      // Remove requests with a zero polling interval since the request has now been made
      this.cullImmediateRequests();

      // Check to make sure we still have subscribers after culling
      // immediate requests
      if (this.subscribers) {
        // if we still have subscribers, set up the next fetch
        if (this.pollingInterval > 0) {
          this.setupNextFetch();
        } else {
          this.timeout = undefined;
        }
      }
    }, wait);
  }


  // **addSubscription**<br/>
  // @param [subscriber]: Object<br/>
  // The subscription to add. May contain a pollingInterval in ms, and a params object.
  //
  // Add a subscription to the channel, causing the params to update. A fetch may be scheduled or rescheduled.
  addSubscription(subscriber) {
    if (!_.includes(this.subscribers, subscriber)) {
      this.subscribers.push(subscriber);

      this.onSubscriptionsChanged();
    }
  }


  // **removeSubscription**<br/>
  // @param [subscriber]: Object<br/>
  // The subscription to remove. This must be the same reference as the object used when subscribing (i.e. ===).
  //
  // Remove a subscription to the channel, causing the params to update. The next fetch may be rescheduled or the
  // channel may be stopped if this is the last subscriber.
  removeSubscription(subscriber) {
    if (_.includes(this.subscribers, subscriber)) {
      this.subscribers = _.without(this.subscribers, subscriber);

      if (this.subscribers.length === 0) {
        this.stop();
      } else {
        this.onSubscriptionsChanged();
      }
    }
  }

  // **onSubscriptionsChanged**<br/>
  // Updates the params and reschedules the next fetch if necessary.
  onSubscriptionsChanged() {
    const params = this.getParams();
    const didParamsChange = !_.isEqual(params, this.params);

    const oldParams = this.params;
    this.params = params;

    let shouldFetchImmediately = false;

    if (didParamsChange) {
      shouldFetchImmediately = this.service.shouldFetchOnParamsUpdate(this.params, oldParams, this.name);
    }

    if (shouldFetchImmediately) {
      this.lastPollTime = undefined;
      this.restart();

    } else if (this.getPollingInterval() !== this.pollingInterval) {
      this.restart();
    }
  }


  // **getPollingInterval**<br/>
  // @returns [pollingInterval]: Number<br/>
  // The current polling interval in ms.
  //
  // Returns the lowest polling interval of subscribers. If no subscriber has a polling interval,
  // returns 0 which represents an immediate request.
  getPollingInterval() {
    const pollingIntervals = _.map(this.subscribers, subscriber => subscriber.pollingInterval);
    const pollingInterval = _.min(pollingIntervals);
    if (pollingInterval === Infinity) {
      return 0;
    } else {
      return pollingInterval;
    }
  }


  // **getParams**<br/>
  // @returns [params]: Object<br/>
  // The current consolidated params for this channel.
  //
  // A channel always holds an up-to-date copy of the consilidated params.
  // This method updates those params, and is called whenever a subscriber is
  // added or removed.
  getParams() {
    let params = _.map(this.subscribers, subscriber => subscriber.params);
    params = _.compact(params);
    return this.service.consolidateParams(params, this.name);
  }


  // **cullImmediateRequests**<br/>
  // Removes all subscribers that do not have a polling interval.
  cullImmediateRequests() {
    let immediateRequests = _.filter(this.subscribers, (subscriber) => {
      return (subscriber.pollingInterval === undefined) || (subscriber.pollingInterval === 0);
    });

    // Remove the immediate requests. This will never trigger a
    // restart because the polling interval is zero and cannot be lowered
    _.each(immediateRequests, (immediateRequest) => {
      return this.removeSubscription(immediateRequest);
    });

    this.pollingInterval = this.getPollingInterval();
  }
}


// ## APIService
// An API service makes XHRs when it is subscribed to.
class APIService {

  static get extend() {
    return Model.extend;
  }

  // Optionally pass in a window object to stub Date, set/clearTimeout for testing
  constructor(_window = window) {
    const service = this;
    // An object referencing the channels owned by this service by name
    this.channels = {};
    this._window = _window;

    this.Model = Model.extend({
      sync(method, model, options) {
        return service.sync(method, model, options);
      },

      url() {
        return service.url(this);
      },

      parse(resp, options) {
        return service.parse(resp, options, this);
      }
    });
  }

  // **consolidateParams**<br/>
  // @param [paramsArray]: Array&lt;Object&gt;<br/>
  // An array of all of the params of all of the subscribers on a channel
  //
  // @param [channelName]: String<br/>
  // The name of the channel
  //
  // @returns [params]: Object
  // The consolidated params that should be used for the request
  //
  // Converts an array of params for the subscribers on this channel into
  // a single params object. The default implementation just returns the first
  // params object in the array. This is fine when using the default implementation of
  // channelForParams because all the params are identical anyway.
  consolidateParams(paramsArray, channelName) {
    return paramsArray[0];
  }


  // **channelForParams**<br/>
  // @param [params]: Object<br/>
  // The params to be added to a channel
  //
  // @returns [channelName]: String<br/>
  // The name of the channel to add the params to
  //
  // Returns the name of the channel that should request data for the given params.
  // By default, only subscribers with identical params are put on the same channel
  channelForParams(params) {
    // `null`/`undefined` should be equivalent to an empty params object
    return (JSON.stringify(params)) || "{}";
  }


  // **shouldFetchOnParamsUpdate**<br/>
  // @param [newParams]: Object<br/>
  // The new consolidated params object
  //
  // @param [oldParams]: Object<br/>
  // The old consolidated params object
  //
  // @param [channelName]: String<br/>
  // The name of the channel that the params are for.
  //
  // This method is called by the service channel when its consolidated params change.
  // Return true if the service should fetch immediately after the given params update, or
  // false if the service should wait until the next scheduled poll time.<br/>
  // The default implementation always returns true, forcing an immediate fetch.
  shouldFetchOnParamsUpdate(newParams, oldParams, channelName) {
    return true;
  }


  // **onFetchSuccess**<br/>
  // Called when a fetch is successful.
  onFetchSuccess() {}

  // **onFetchError**<br/>
  // Called when a fetch is unsuccessful.
  onFetchError() {}

  // **onPostSuccess**<br/>
  // Called when a post request is successful.
  onPostSuccess() {}

  // **onPostError**<br/>
  // Called when a post request is unsuccessful.
  onPostError() {}


  // **sync**<br/>
  // See [Backbone.Model.sync](http://backbonejs.org/#Model-sync)
  sync(method, model, options) {
    return Model.prototype.sync.call(model, method, model, options);
  }

  // **url**<br/>
  // See [Backbone.Model.url](http://backbonejs.org/#Model-url)
  url(model) {
    Model.prototype.url.call(model);
  }

  // **parse**<br/>
  // See [Backbone.Model.parse](http://backbonejs.org/#Model-parse)
  parse(resp, options, model) {
    Model.prototype.parse.call(model);
  }

  // **removeChannel**<br/>
  // @param [channel]: String<br/>
  // The name of the channel to remove
  //
  // Removes the given channel. Called by channels when they are no longer required.
  removeChannel(channel) {
    delete this.channels[channel.name];
  }

  // **addSubscription**<br/>
  // @param [subscriber]: Object
  // A subscription to the service. This must contain an HTTP method: `GET` and `POST` are currently supported.<br/>
  // For fetches, this should also contain a `params` object and optionally a `pollingInterval` in ms.<br/>
  // For posts, this should contain a `postParams` object.
  //
  // Adds a subscription to the service, triggering a request.
  addSubscription(subscriber) {
    const method = subscriber.method || 'GET';
    switch (method) {
      case 'GET':
        return this.addGetSubscription(subscriber);
      case 'POST':
        return this.post(subscriber.postParams);
      case 'PUT':
        throw 'PUT not yet implemented';
      case 'DELETE':
        throw 'DELETE not yet implemented';
    }
  }


  // **addGetSubscription**<br/>
  // @param @param [subscriber]: Object<br/>
  // A subscription to the service. This should contain a params object and optionally a pollingInterval in ms.
  //
  // Adds a subscription to the service, triggering a fetch request.
  addGetSubscription(subscriber) {
    const channelName = this.channelForParams(subscriber.params);
    const channel = this.channels[channelName];

    if (channel) {
      channel.addSubscription(subscriber);

    } else {
      this.channels[channelName] = new ServiceChannel(this._window, channelName, this, [subscriber]);
    }
  }


  // **removeSubscription**<br/>
  // @param [subscriber]: Object<br/>
  // A subscription to the service. This must be the same reference as the object used when subscribing (i.e. ===)
  //
  // Removes a subscription to the service.
  removeSubscription(subscriber) {
    if (subscriber) {
      const channelId = this.channelForParams(subscriber.params);
      const channel = this.channels[channelId];

      if (channel) {
        channel.removeSubscription(subscriber);
      }
    }
  }

  // **getModelInstance**<br/>
  // @param [params]: Object<br/>
  // The params for the request.
  //
  // @returns [modelInstance]: [Backbone.Model](http://backbonejs.org/#Model)
  // The Backbone model on which XHR requests are performed.
  //
  // Returns a Backbone model on which XHR requests are performed.
  getModelInstance(params) {
    return new this.Model(params);
  }


  // **propagateResponse**<br/>
  // See [Backbone.Events.trigger](http://backbonejs.org/#Events-trigger)
  propagateResponse(key, responseData) {
    return this.trigger(key, responseData);
  }


  // **fetch**<br/>
  // @param [params]: Object<br/>
  // The consolidated params for a request
  //
  // Makes a fetch request with the given params. Either onFetchSuccess or onFetchError
  // will be called when the request is resolved.
  fetch(params) {
    const model = this.getModelInstance(params);
    return model.fetch({
      success: this.onFetchSuccess,
      error: this.onFetchError
    });
  }

  // **post**<br/>
  // @param [params]: Object<br/>
  // The consolidated params for a request
  //
  // Makes a post request with the given params. Either onPostSuccess or onPostError
  // will be called when the request is resolved.
  post(params) {
    const model = this.getModelInstance(params);
    return model.save(undefined, {
      success: this.onPostSuccess,
      error: this.onPostError
    });
  }
}

_.extend(APIService.prototype, Events);

export default APIService;