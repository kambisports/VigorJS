(function() {
  
/*!
(c) 2012 Uzi Kilon, Splunk Inc.
Backbone Poller 0.3.0
https://github.com/uzikilon/backbone-poller
Backbone Poller may be freely distributed under the MIT license.
*/
(function (root, factory) {
  'use strict';
  if (typeof define == 'function' && define.amd) {
    define(['underscore', 'backbone'], factory);
  }
  else if (typeof require === 'function' && typeof exports === 'object') {
    module.exports = factory(require('underscore'), require('backbone'));
  }
  else {
    root.Backbone.Poller = factory(root._, root.Backbone);
  }
}(this, function (_, Backbone) {
  'use strict';

  // Default settings
  var defaults = {
    delay: 1000,
    backoff: false,
    condition: function () {
      return true;
    }
  };

  // Available events
  var events = ['start', 'stop', 'fetch', 'success', 'error', 'complete' ];

  var pollers = [];
  function findPoller(model) {
    return _.find(pollers, function (poller) {
      return poller.model === model;
    });
  }

  var PollingManager = {

    // **Backbone.Poller.get(model[, options])**
    // <pre>
    // Returns a singleton instance of a poller for a model
    // Stops it if running
    // If options.autostart is true, will start it
    // Returns a poller instance
    // </pre>
    get: function (model, options) {
      var poller = findPoller(model);
      if (!poller) {
        poller = new Poller(model, options);
        pollers.push(poller);
      }
      else {
        poller.set(options);
      }
      if (options && options.autostart === true) {
        poller.start({silent: true});
      }
      return poller;
    },

    // **Backbone.Poller.size()**
    // <pre>
    // Returns the number of instantiated pollers
    // </pre>
    size: function () {
      return pollers.length;
    },

    // **Backbone.Poller.reset()**
    // <pre>
    // Stops all pollers and removes from the pollers pool
    // </pre>
    reset: function () {
      while (pollers.length) {
        pollers.pop().stop();
      }
    }
  };

  function Poller(model, options) {
    this.model = model;
    this.set(options);
  }

  _.extend(Poller.prototype, Backbone.Events, {

    // **poller.set([options])**
    // <pre>
    // Reset poller options and stops the poller
    // </pre>
    set: function (options) {
      this.options = _.extend({}, defaults, options || {});
      if (this.options.flush) {
        this.off();
      }
      _.each(events, function (name) {
        var callback = this.options[name];
        if (_.isFunction(callback)) {
          this.off(name, callback, this);
          this.on(name, callback, this);
        }
      }, this);

      if (this.model instanceof Backbone.Model) {
        this.model.on('destroy', this.stop, this);
      }

      return this.stop({silent: true});
    },
    //
    // **poller.start([options])**
    // <pre>
    // Start the poller
    // Returns a poller instance
    // Triggers a 'start' events unless options.silent is set to true
    // </pre>
    start: function (options) {
      if (!this.active()) {
        options && options.silent || this.trigger('start', this.model);
        this.options.active = true;
        if (this.options.delayed) {
          delayedRun(this);
        } else {
          run(this);
        }
      }
      return this;
    },
    // **poller.stop([options])**
    // <pre>
    // Stops the poller
    // Aborts any running XHR call
    // Returns a poller instance
    // Triggers a 'stop' events unless options.silent is set to true
    // </pre>
    stop: function (options) {
      options && options.silent || this.trigger('stop', this.model);
      this.options.active = false;
      this.xhr && this.xhr.abort && this.xhr.abort();
      this.xhr = null;
      clearTimeout(this.timeoutId);
      this.timeoutId = null;
      return this;
    },
    // **poller.active()**
    // <pre>
    // Returns a boolean for poller status
    // </pre>
    active: function () {
      return this.options.active === true;
    }
  });

  function run(poller) {
    if (validate(poller)) {
      var options = _.extend({}, poller.options, {
        success: function (model, resp) {
          poller.trigger('success', model, resp);
          delayedRun(poller);
        },
        error: function (model, resp) {
          if (poller.options.continueOnError) {
            poller.trigger('error', model, resp);
            delayedRun(poller);
          } else {
            poller.stop({silent: true});
            poller.trigger('error', model, resp);
          }
        }
      });
      poller.trigger('fetch', poller.model);
      poller.xhr = poller.model.fetch(options);
    }
  }

  function getDelay(poller) {
    if (!poller.options.backoff) {
      return poller.options.delay;
    }
    poller._backoff = poller._backoff ? Math.min(poller._backoff * 1.1, 30) : 1;
    return Math.round(poller.options.delay * poller._backoff);
  }

  function delayedRun(poller) {
    if (validate(poller)) {
      poller.timeoutId = _.delay(run, getDelay(poller), poller);
    }
  }

  function validate(poller) {
    if (! poller.options.active) {
      return false;
    }
    if (poller.options.condition(poller.model) !== true) {
      poller.stop({silent: true});
      poller.trigger('complete', poller.model);
      return false;
    }
    return true;
  }

  PollingManager.getDelay   = getDelay;         // test hook
  PollingManager.prototype  = Poller.prototype; // test hook

  return PollingManager;

}));


;
  var __indexOf = [].indexOf || function(item) { for (var i = 0, l = this.length; i < l; i++) { if (i in this && this[i] === item) return i; } return -1; },
    __bind = function(fn, me){ return function(){ return fn.apply(me, arguments); }; },
    __hasProp = {}.hasOwnProperty,
    __extends = function(child, parent) { for (var key in parent) { if (__hasProp.call(parent, key)) child[key] = parent[key]; } function ctor() { this.constructor = child; } ctor.prototype = parent.prototype; child.prototype = new ctor(); child.__super__ = parent.prototype; return child; },
    __slice = [].slice;

  (function(root, factory) {
    var Backbone, _;
    if (typeof define === "function" && define.amd) {
      define(['backbone', 'underscore'], function(Backbone, _) {
        return factory(root, Backbone, _);
      });
      console.log('amd');
    } else if (typeof exports === "object") {
      Backbone = require('backbone');
      _ = require('underscore');
      console.log('commonjs');
      module.exports = factory(root, Backbone, _);
    } else {
      console.log('global');
      root.Vigor = factory(root, root.Backbone, root._);
    }
  })(this, function(root, Backbone, _) {
    var ApiService, ComponentIdentifier, ComponentView, DataCommunicationManager, EventBus, EventRegistry, PackageBase, Poller, Producer, ProducerManager, ProducerMapper, Repository, ServiceRepository, ViewModel, Vigor, previousVigor;
    previousVigor = root.Vigor;
    Vigor = Backbone.Vigor = {};
    Vigor.noConflict = function() {
      return root.Vigor = previousVigor;
    };
    Vigor.extend = Backbone.Model.extend;
    EventRegistry = (function() {
      function EventRegistry() {
        _.extend(this, Backbone.Events);
      }

      return EventRegistry;

    })();
    EventBus = (function() {
      function EventBus() {}

      EventBus.prototype.eventRegistry = new EventRegistry();

      EventBus.prototype.subscribe = function(key, callback) {
        if (!this._eventKeyExists(key)) {
          throw "key '" + key + "' does not exist in EventKeys";
        }
        if ('function' !== typeof callback) {
          throw "callback is not a function";
        }
        return this.eventRegistry.on(key, callback);
      };

      EventBus.prototype.subscribeOnce = function(key, callback) {
        if (!this._eventKeyExists(key)) {
          throw "key '" + key + "' does not exist in EventKeys";
        }
        if ('function' !== typeof callback) {
          throw "callback is not a function";
        }
        return this.eventRegistry.once(key, callback);
      };

      EventBus.prototype.unsubscribe = function(key, callback) {
        if (!this._eventKeyExists(key)) {
          throw "key '" + key + "' does not exist in EventKeys";
        }
        if ('function' !== typeof callback) {
          throw "callback is not a function";
        }
        return this.eventRegistry.off(key, callback);
      };

      EventBus.prototype.send = function(key, message) {
        if (!this._eventKeyExists(key)) {
          throw "key '" + key + "' does not exist in EventKeys";
        }
        return this.eventRegistry.trigger(key, message);
      };

      EventBus.prototype._eventKeyExists = function(key) {
        var property, value;
        return __indexOf.call((function() {
          var _ref, _results;
          _ref = Vigor.EventKeys;
          _results = [];
          for (property in _ref) {
            value = _ref[property];
            _results.push(value);
          }
          return _results;
        })(), key) >= 0;
      };

      return EventBus;

    })();
    Vigor.EventBus = new EventBus();
    PackageBase = (function() {
      function PackageBase() {
        _.extend(this, Backbone.Events);
      }

      PackageBase.prototype.render = function() {
        throw 'PackageBase->render needs to be over-ridden';
      };

      PackageBase.prototype.dispose = function() {
        throw 'PackageBase->dispose needs to be over-ridden';
      };

      return PackageBase;

    })();
    PackageBase.extend = Vigor.extend;
    Vigor.PackageBase = PackageBase;
    Producer = (function() {
      Producer.prototype.subscriptionKeyToComponents = {};

      function Producer() {
        this._addKeysToMap();
      }

      Producer.prototype.addComponent = function(subscriptionKey, componentIdentifier) {
        var key, registeredComponents;
        key = subscriptionKey.key;
        registeredComponents = this.subscriptionKeyToComponents[key];
        if (!registeredComponents) {
          throw new Error('Unknown subscription key, could not add component!');
        }
        return this.subscriptionKeyToComponents[key].push(componentIdentifier);
      };

      Producer.prototype.produce = function(subscriptionKey, data, filterFn) {
        var component, componentsForSubscription, componentsInterestedInChange, key, _i, _len, _results;
        if (filterFn == null) {
          filterFn = function() {};
        }
        key = subscriptionKey.key;
        this._validateContract(subscriptionKey, data);
        componentsForSubscription = this.subscriptionKeyToComponents[key];
        componentsInterestedInChange = _.filter(componentsForSubscription, function(componentIdentifier) {
          return _.isEmpty(componentIdentifier.options) || filterFn(componentIdentifier.options);
        });
        _results = [];
        for (_i = 0, _len = componentsInterestedInChange.length; _i < _len; _i++) {
          component = componentsInterestedInChange[_i];
          _results.push(component.callback(data));
        }
        return _results;
      };

      Producer.prototype.subscribe = function(subscriptionKey, options) {
        throw new Error("Subscription handler should be overriden in subclass! Implement for subscription " + subscriptionKey + " with options " + options);
      };

      Producer.prototype.dispose = function() {
        throw new Error("Dispose shuld be overriden in subclass!");
      };

      Producer.prototype.extend = function(obj, mixin) {
        var method, name;
        for (name in mixin) {
          method = mixin[name];
          obj[name] = method;
        }
        return obj;
      };

      Producer.prototype.mixin = function(instance, mixin) {
        return this.extend(instance, mixin);
      };

      Producer.prototype.decorate = function(data, decoratorList) {
        var decorator, _i, _len;
        for (_i = 0, _len = decoratorList.length; _i < _len; _i++) {
          decorator = decoratorList[_i];
          decorator(data);
        }
        return data;
      };

      Producer.prototype.modelsToJSON = function(models) {
        var modelsJSON;
        modelsJSON = _.map(models, function(model) {
          return model.toJSON();
        });
        return modelsJSON;
      };

      Producer.prototype._validateContract = function(subscriptionKey, dataToProduce) {
        var contract, contractKeyCount, dataKeyCount, key, val;
        contract = subscriptionKey.contract;
        if (!contract) {
          throw new Error("The " + subscriptionKey.key + " does not have any contract specified");
          return false;
        }
        if (!dataToProduce) {
          throw new Error("" + this.NAME + " is calling produce without any data");
          return false;
        }
        contractKeyCount = _.keys(contract).length;
        dataKeyCount = _.keys(dataToProduce).length;
        if (dataKeyCount > contractKeyCount) {
          console.warn("" + this.NAME + " is calling produce with more data then what is specified in the contract");
        } else if (dataKeyCount < contractKeyCount) {
          console.warn("" + this.NAME + " is calling produce with less data then what is specified in the contract");
        }
        for (key in contract) {
          val = contract[key];
          if (val != null) {
            if (typeof dataToProduce[key] !== typeof val) {
              console.warn("" + this.NAME + " is producing data of the wrong type according to the contract, " + key + ", expects " + (typeof val) + " but gets " + (typeof dataToProduce[key]));
            }
          }
          if (!(key in dataToProduce)) {
            console.warn("" + this.NAME + " producing data but is missing the key: " + key);
          }
        }
        return true;
      };

      Producer.prototype._addKeysToMap = function() {
        var subscriptionKey, _i, _len, _ref, _results;
        _ref = this.SUBSCRIPTION_KEYS;
        _results = [];
        for (_i = 0, _len = _ref.length; _i < _len; _i++) {
          subscriptionKey = _ref[_i];
          _results.push(this.subscriptionKeyToComponents[subscriptionKey.key] = []);
        }
        return _results;
      };

      Producer.prototype.SUBSCRIPTION_KEYS = [];

      Producer.prototype.NAME = 'Producer';

      return Producer;

    })();
    Producer.extend = Vigor.extend;
    Vigor.Producer = Producer;
    ProducerMapper = (function() {
      ProducerMapper.prototype.producers = [];

      ProducerMapper.prototype.subscriptionKeyToProducerMap = {};

      function ProducerMapper() {
        this._buildMap();
      }

      ProducerMapper.prototype.findProducerClassForSubscription = function(subscriptionKey) {
        var key, producerClass;
        key = subscriptionKey.key;
        producerClass = this.subscriptionKeyToProducerMap[key];
        if (!(this.producers.length > 0)) {
          throw "There are no producers registered - register producers through the DataCommunicationManager";
        }
        if (!producerClass) {
          throw "No producer found for subscription " + key + "!";
        }
        return producerClass;
      };

      ProducerMapper.prototype.addProducerClass = function(producerClass) {
        if (this.producers.indexOf(producerClass) === -1) {
          this.producers.push(producerClass);
          this._buildMap();
        }
        return this;
      };

      ProducerMapper.prototype.removeProducerClass = function(producerClass) {
        var index;
        index = this.producers.indexOf(producerClass);
        if (index !== -1) {
          this.producers.splice(index, 1);
          producerClass.prototype.SUBSCRIPTION_KEYS.forEach((function(_this) {
            return function(subscriptionKey) {
              var key;
              key = subscriptionKey.key;
              return delete _this.subscriptionKeyToProducerMap[key];
            };
          })(this));
          this._buildMap();
        }
        return this;
      };

      ProducerMapper.prototype.removeAllProducers = function() {
        this.producers = [];
        return this.subscriptionKeyToProducerMap = {};
      };

      ProducerMapper.prototype._buildMap = function() {
        return this.producers.forEach((function(_this) {
          return function(producer) {
            return producer.prototype.SUBSCRIPTION_KEYS.forEach(function(subscriptionKey) {
              var key;
              key = subscriptionKey.key;
              return _this.subscriptionKeyToProducerMap[key] = producer;
            });
          };
        })(this));
      };

      return ProducerMapper;

    })();
    Vigor.ProducerMapper = ProducerMapper;
    ProducerManager = (function() {
      function ProducerManager() {}

      ProducerManager.prototype.producerMapper = new Vigor.ProducerMapper();

      ProducerManager.prototype.instansiatedProducers = {};

      ProducerManager.prototype.addProducersToMap = function(producers) {
        var producerClass, _i, _len, _results;
        if (_.isArray(producers)) {
          _results = [];
          for (_i = 0, _len = producers.length; _i < _len; _i++) {
            producerClass = producers[_i];
            _results.push(this.producerMapper.addProducerClass(producerClass));
          }
          return _results;
        } else {
          return this.producerMapper.addProducerClass(producers);
        }
      };

      ProducerManager.prototype.removeProducersFromMap = function(producers) {
        var producerClass, _i, _len, _results;
        if (_.isArray(producers)) {
          _results = [];
          for (_i = 0, _len = producers.length; _i < _len; _i++) {
            producerClass = producers[_i];
            _results.push(this.producerMapper.removeProducerClass(producerClass));
          }
          return _results;
        } else {
          return this.producerMapper.removeProducerClass(producers);
        }
      };

      ProducerManager.prototype.removeAllProducersFromMap = function() {
        return this.producerMapper.removeAllProducers();
      };

      ProducerManager.prototype.getProducer = function(subscriptionKey) {
        var producerClass;
        producerClass = this.producerMapper.findProducerClassForSubscription(subscriptionKey);
        return this._instansiateProducer(producerClass);
      };

      ProducerManager.prototype.removeProducer = function(subscriptionKey) {
        var producer, producerClass;
        producerClass = this.producerMapper.findProducerClassForSubscription(subscriptionKey);
        producer = this.instansiatedProducers[producerClass.prototype.NAME];
        if (producer) {
          producer.dispose();
          return delete this.instansiatedProducers[producerClass.prototype.NAME];
        }
      };

      ProducerManager.prototype.addComponentToProducer = function(subscriptionKey, componentIdentifier) {
        var producer;
        producer = this.getProducer(subscriptionKey);
        return producer.addComponent(subscriptionKey, componentIdentifier);
      };

      ProducerManager.prototype.subscribe = function(subscriptionKey, options) {
        var producer, producerClass;
        producerClass = this.producerMapper.findProducerClassForSubscription(subscriptionKey);
        producer = this._instansiateProducer(producerClass);
        return producer.subscribe(subscriptionKey, options);
      };

      ProducerManager.prototype._instansiateProducer = function(producerClass) {
        var producer;
        if (!this.instansiatedProducers[producerClass.prototype.NAME]) {
          producer = new producerClass();
          this.instansiatedProducers[producerClass.prototype.NAME] = producer;
        }
        return this.instansiatedProducers[producerClass.prototype.NAME];
      };

      return ProducerManager;

    })();
    Vigor.ProducerManager = ProducerManager;

    /*
      Base class for services interacting with the API (polling)
      Each service is bound to a repository and whenever that repository has a listener
      for data, the service will start polling. If the repository has no active listeners the
      service will stop polling for data.
     */
    Poller = Backbone.Poller;
    ServiceRepository = Vigor.ServiceRepository;
    ApiService = (function() {
      ApiService.prototype.service = void 0;

      ApiService.prototype.poller = void 0;

      ApiService.prototype.pollerOptions = void 0;

      ApiService.prototype.shouldStop = false;

      ApiService.prototype.url = void 0;

      function ApiService(repository, pollInterval) {
        this.repository = repository;
        if (pollInterval == null) {
          pollInterval = 10000;
        }
        this.stopPolling = __bind(this.stopPolling, this);
        this.startPolling = __bind(this.startPolling, this);
        this.parse = __bind(this.parse, this);
        this.service = new Backbone.Model();
        this.service.url = this.url;
        this.service.parse = this.parse;
        this.pollerOptions = {
          delay: pollInterval,
          delayed: false,
          continueOnError: true,
          autostart: false
        };
        this._createPoller(this.pollerOptions);
      }

      ApiService.prototype.dispose = function() {
        this._unbindPollerListeners();
        this.service = void 0;
        return this.poller = void 0;
      };

      ApiService.prototype.parse = function(response) {
        this._validateResponse(response !== true);
        if (this.shouldStop) {
          return this.poller.stop();
        }
      };

      ApiService.prototype.run = function() {
        throw 'ApiService->run must be overriden.';
      };

      ApiService.prototype.startPolling = function() {
        var _ref;
        return (_ref = this.poller) != null ? _ref.start() : void 0;
      };

      ApiService.prototype.stopPolling = function() {
        if (this.poller.active()) {
          return this.shouldStop = true;
        } else {
          return this.poller.stop();
        }
      };

      ApiService.prototype.propagateResponse = function(key, responseData) {
        return this.trigger(key, responseData);
      };

      ApiService.prototype._createPoller = function(options) {
        this.poller = Poller.get(this.service, options);
        this._unbindPollerListeners();
        return this._bindPollerListeners();
      };

      ApiService.prototype._bindPollerListeners = function() {

        /*
        @poller.on 'success',  ->
          window.console.log 'Api service poller success'
          
        @poller.on 'complete', ->
          window.console.log 'Api service poller complete'
         */
        return this.poller.on('error', function(e) {
          return window.console.log('Api service poller error', arguments, this);
        });
      };

      ApiService.prototype._unbindPollerListeners = function() {
        var _ref;
        return (_ref = this.poller) != null ? _ref.off() : void 0;
      };

      ApiService.prototype._validateResponse = function(response) {
        var removeThisLineOfCode;
        removeThisLineOfCode = response;
        return true;
      };

      _.extend(ApiService.prototype, Backbone.Events);

      return ApiService;

    })();
    ApiService.extend = Vigor.extend;
    Vigor.ApiService = ApiService;
    Vigor.SubscriptionKeys = {
      extend: function(object) {
        return _.extend(this, object);
      }
    };
    Vigor.EventKeys = {
      ALL_EVENTS: 'all',
      extend: function(object) {
        _.extend(this, object);
        return this;
      }
    };
    ComponentIdentifier = (function() {
      ComponentIdentifier.prototype.id = void 0;

      ComponentIdentifier.prototype.callback = void 0;

      ComponentIdentifier.prototype.options = void 0;

      function ComponentIdentifier(componentId, componentCb, componentOptions) {
        this.id = componentId;
        this.callback = componentCb;
        this.options = componentOptions;
      }

      return ComponentIdentifier;

    })();
    Vigor.ComponentIdentifier = ComponentIdentifier;
    DataCommunicationManager = (function() {
      ProducerManager = Vigor.ProducerManager;

      ComponentIdentifier = Vigor.ComponentIdentifier;

      DataCommunicationManager.prototype.subscriptionsWithComponentIdentifiers = void 0;

      DataCommunicationManager.prototype.subscriptionsWithProducers = void 0;

      DataCommunicationManager.prototype.producerManager = void 0;

      DataCommunicationManager.prototype.apiServices = void 0;

      function DataCommunicationManager() {
        this.subscriptionsWithComponentIdentifiers = {};
        this.subscriptionsWithProducers = {};
        this.producerManager = new ProducerManager();
      }

      DataCommunicationManager.prototype.registerProducers = function(producers) {
        return this.producerManager.addProducersToMap(producers);
      };

      DataCommunicationManager.prototype.unregisterProducers = function(producers) {
        return this.producerManager.removeProducersFromMap(producers);
      };

      DataCommunicationManager.prototype.unregisterAllProducers = function() {
        return this.producerManager.removeAllProducersFromMap();
      };

      DataCommunicationManager.prototype.subscribe = function(componentId, subscriptionKey, subscriptionCb, subscriptionOptions) {
        var componentIdentifier, keys;
        if (subscriptionOptions == null) {
          subscriptionOptions = {};
        }
        componentIdentifier = new ComponentIdentifier(componentId, subscriptionCb, subscriptionOptions);
        keys = _.keys(this.subscriptionsWithComponentIdentifiers);
        if (_.indexOf(keys, subscriptionKey.key) === -1) {
          this._createSubscription(subscriptionKey);
        }
        this._addComponentToSubscription(subscriptionKey, componentIdentifier);
        return this.producerManager.subscribe(subscriptionKey, subscriptionOptions);
      };

      DataCommunicationManager.prototype.unsubscribe = function(componentId, subscriptionKey) {
        return this._removeComponentFromSubscription(subscriptionKey, componentId);
      };

      DataCommunicationManager.prototype.unsubscribeAll = function(componentId) {
        var keys, len, _results;
        keys = _.keys(this.subscriptionsWithComponentIdentifiers);
        len = keys.length;
        _results = [];
        while (len--) {
          _results.push(this._removeComponentFromSubscription(keys[len], componentId));
        }
        return _results;
      };

      DataCommunicationManager.prototype._createSubscription = function(subscriptionKey) {
        var key, producer;
        key = subscriptionKey.key;
        this.subscriptionsWithComponentIdentifiers[key] = [];
        producer = this.producerManager.getProducer(subscriptionKey);
        return this.subscriptionsWithProducers[key] = producer;
      };

      DataCommunicationManager.prototype._removeSubscription = function(subscriptionKey) {
        var key;
        key = subscriptionKey.key;
        delete this.subscriptionsWithComponentIdentifiers[key];
        delete this.subscriptionsWithProducers[key];
        return this.producerManager.removeProducer(subscriptionKey);
      };

      DataCommunicationManager.prototype._addComponentToSubscription = function(subscriptionKey, componentIdentifier) {
        var existingComponent, key, subscriptionComponents;
        key = subscriptionKey.key;
        subscriptionComponents = this.subscriptionsWithComponentIdentifiers[key];
        existingComponent = _.find(subscriptionComponents, function(component) {
          return component.id === componentIdentifier.id;
        });
        if (!existingComponent) {
          subscriptionComponents.push(componentIdentifier);
          return this.producerManager.addComponentToProducer(subscriptionKey, componentIdentifier);
        }
      };

      DataCommunicationManager.prototype._removeComponentFromSubscription = function(subscriptionKey, componentId) {
        var component, componentIndex, components, index, key, _i, _len;
        key = subscriptionKey.key;
        components = this.subscriptionsWithComponentIdentifiers[key];
        componentIndex = -1;
        for (index = _i = 0, _len = components.length; _i < _len; index = ++_i) {
          component = components[index];
          if (component.id === componentId) {
            componentIndex = index;
          }
        }
        if (componentIndex > -1) {
          components.splice(componentIndex, 1);
        }
        if (!this._isSubscriptionValid(subscriptionKey)) {
          return this._removeSubscription(subscriptionKey);
        }
      };

      DataCommunicationManager.prototype._isSubscriptionValid = function(subscriptionKey) {
        var componentIdentifiers, key;
        key = subscriptionKey.key;
        componentIdentifiers = this.subscriptionsWithComponentIdentifiers[key];
        if (_.isEmpty(componentIdentifiers)) {
          return false;
        } else {
          return true;
        }
      };

      DataCommunicationManager.prototype.makeTestInstance = function() {
        return new DataCommunicationManager();
      };

      return DataCommunicationManager;

    })();
    Vigor.DataCommunicationManager = new DataCommunicationManager();
    ComponentView = (function(_super) {
      __extends(ComponentView, _super);

      ComponentView.prototype.viewModel = void 0;

      function ComponentView() {
        this._checkIfImplemented(['renderStaticContent', 'renderDynamicContent', 'addSubscriptions', 'removeSubscriptions', 'dispose']);
        ComponentView.__super__.constructor.apply(this, arguments);
      }

      ComponentView.prototype.initialize = function(options) {
        ComponentView.__super__.initialize.apply(this, arguments);
        if (options.viewModel) {
          this.viewModel = options.viewModel;
        }
        return this;
      };

      ComponentView.prototype.render = function() {
        this.renderStaticContent();
        this.addSubscriptions();
        return this;
      };

      ComponentView.prototype.renderStaticContent = function() {
        return this;
      };

      ComponentView.prototype.renderDynamicContent = function() {
        return this;
      };

      ComponentView.prototype.addSubscriptions = function() {
        return this;
      };

      ComponentView.prototype.removeSubscriptions = function() {
        return this;
      };

      ComponentView.prototype.dispose = function() {
        var _ref;
        if ((_ref = this.model) != null) {
          _ref.unbind();
        }
        this.removeSubscriptions();
        this.stopListening();
        this.$el.off();
        this.$el.remove();
        return this.off();
      };

      ComponentView.prototype._checkIfImplemented = function(methodNames) {
        var methodName, _i, _len, _results;
        _results = [];
        for (_i = 0, _len = methodNames.length; _i < _len; _i++) {
          methodName = methodNames[_i];
          if (!this.constructor.prototype.hasOwnProperty(methodName)) {
            throw new Error("" + this.constructor.name + " - " + methodName + "() must be implemented in View.");
          } else {
            _results.push(void 0);
          }
        }
        return _results;
      };

      return ComponentView;

    })(Backbone.View);
    Vigor.ComponentView = ComponentView;
    ViewModel = (function() {
      DataCommunicationManager = Vigor.DataCommunicationManager;

      ViewModel.prototype.id = 'ViewModel';

      ViewModel.prototype.subscriptionIds = [];

      function ViewModel() {
        this.id = this.getUniqueId();
      }

      ViewModel.prototype.getUniqueId = function() {
        return "" + this.id + "_" + (_.uniqueId());
      };

      ViewModel.prototype.dispose = function() {
        return this.unsubscribeAll();
      };

      ViewModel.prototype.subscribe = function(key, callback, options) {
        return DataCommunicationManager.subscribe(this.id, key, callback, options);
      };

      ViewModel.prototype.unsubscribe = function(key) {
        return DataCommunicationManager.unsubscribe(this.id, key);
      };

      ViewModel.prototype.unsubscribeAll = function() {
        return DataCommunicationManager.unsubscribeAll(this.id);
      };

      return ViewModel;

    })();
    ViewModel.extend = Vigor.extend;
    Vigor.ViewModel = ViewModel;
    Repository = (function(_super) {
      __extends(Repository, _super);

      function Repository() {
        this._debounced = __bind(this._debounced, this);
        this._onRemove = __bind(this._onRemove, this);
        this._onChange = __bind(this._onChange, this);
        this._onAdd = __bind(this._onAdd, this);
        return Repository.__super__.constructor.apply(this, arguments);
      }

      Repository.prototype._debouncedAddedModels = void 0;

      Repository.prototype._debouncedChangedModels = void 0;

      Repository.prototype._debouncedRemovedModels = void 0;

      Repository.prototype._eventTimeout = void 0;

      Repository.prototype.initialize = function() {
        this._debouncedAddedModels = {};
        this._debouncedChangedModels = {};
        this._debouncedRemovedModels = {};
        this.addDebouncedListeners();
        return Repository.__super__.initialize.apply(this, arguments);
      };

      Repository.prototype.addDebouncedListeners = function() {
        return this.on('all', this._onAll);
      };

      Repository.prototype.getByIds = function(ids) {
        var id, models, _i, _len;
        models = [];
        for (_i = 0, _len = ids.length; _i < _len; _i++) {
          id = ids[_i];
          models.push(this.get(id));
        }
        return models;
      };

      Repository.prototype.isEmpty = function() {
        return this.models.length <= 0;
      };

      Repository.prototype._onAll = function() {
        var args, event;
        event = arguments[0], args = 2 <= arguments.length ? __slice.call(arguments, 1) : [];
        switch (event) {
          case 'add':
            this._onAdd.apply(this, args);
            break;
          case 'change':
            this._onChange.apply(this, args);
            break;
          case 'remove':
            this._onRemove.apply(this, args);
        }
        clearTimeout(this._eventTimeout);
        return this._eventTimeout = setTimeout(this._debounced, 100);
      };

      Repository.prototype._onAdd = function(model) {
        return this._debouncedAddedModels[model.id] = model;
      };

      Repository.prototype._onChange = function(model) {
        return this._debouncedChangedModels[model.id] = model;
      };

      Repository.prototype._onRemove = function(model) {
        return this._debouncedRemovedModels[model.id] = model;
      };

      Repository.prototype._debouncedAdd = function() {
        var event, models;
        event = Repository.prototype.REPOSITORY_ADD;
        models = _.values(this._debouncedAddedModels);
        this._debouncedAddedModels = {};
        if (models.length > 0) {
          this.trigger(event, models, event);
        }
        return models;
      };

      Repository.prototype._debouncedChange = function() {
        var event, models;
        event = Repository.prototype.REPOSITORY_CHANGE;
        models = _.values(this._debouncedChangedModels);
        this._debouncedChangedModels = {};
        if (models.length > 0) {
          this.trigger(event, models, event);
        }
        return models;
      };

      Repository.prototype._debouncedRemove = function() {
        var event, models;
        event = Repository.prototype.REPOSITORY_REMOVE;
        models = _.values(this._debouncedRemovedModels);
        this._debouncedRemovedModels = {};
        if (models.length > 0) {
          this.trigger(event, models, event);
        }
        return models;
      };

      Repository.prototype._debouncedDiff = function(added, changed, removed) {
        var consolidated, event, models;
        event = Repository.prototype.REPOSITORY_DIFF;
        if (added.length || changed.length || removed.length) {
          added = _.difference(added, removed);
          consolidated = _.uniq(added.concat(changed));
          models = {
            added: added,
            changed: changed,
            removed: removed,
            consolidated: consolidated
          };
          return this.trigger(event, models, event);
        }
      };

      Repository.prototype._debounced = function() {
        return this._debouncedDiff(this._debouncedAdd(), this._debouncedChange(), this._debouncedRemove());
      };

      Repository.prototype.REPOSITORY_DIFF = 'repository_diff';

      Repository.prototype.REPOSITORY_ADD = 'repository_add';

      Repository.prototype.REPOSITORY_CHANGE = 'repository_change';

      Repository.prototype.REPOSITORY_REMOVE = 'repository_remove';

      return Repository;

    })(Backbone.Collection);
    Vigor.Repository = Repository;
    ServiceRepository = (function(_super) {
      __extends(ServiceRepository, _super);

      function ServiceRepository() {
        return ServiceRepository.__super__.constructor.apply(this, arguments);
      }

      return ServiceRepository;

    })(Vigor.Repository);
    Vigor.ServiceRepository = ServiceRepository;
    return Vigor;
  });

}).call(this);
