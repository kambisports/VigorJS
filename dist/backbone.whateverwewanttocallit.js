(function() {
  var __indexOf = [].indexOf || function(item) { for (var i = 0, l = this.length; i < l; i++) { if (i in this && this[i] === item) return i; } return -1; },
    __hasProp = {}.hasOwnProperty,
    __extends = function(child, parent) { for (var key in parent) { if (__hasProp.call(parent, key)) child[key] = parent[key]; } function ctor() { this.constructor = child; } ctor.prototype = parent.prototype; child.prototype = new ctor(); child.__super__ = parent.prototype; return child; },
    __bind = function(fn, me){ return function(){ return fn.apply(me, arguments); }; },
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
    var ComponentIdentifier, ComponentView, EventBus, EventRegistry, PackageBase, Producer, Repository, ServiceRepository, ViewModel, Vigor, previousVigor;
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
        if (_.isArray(contract) && _.isArray(dataToProduce) === false) {
          console.warn("" + this.NAME + " is supposed to produce an array but is producing " + (typeof dataToProduce));
        }
        if (_.isObject(contract) && _.isArray(contract) === false) {
          contractKeyCount = _.keys(contract).length;
          dataKeyCount = _.keys(dataToProduce).length;
          if (dataKeyCount > contractKeyCount) {
            console.warn("" + this.NAME + " is calling produce with more data then what is specified in the contract");
          } else if (dataKeyCount < contractKeyCount) {
            console.warn("" + this.NAME + " is calling produce with less data then what is specified in the contract");
          }
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
    (function() {
      var ProducerMapper, producers, subscriptionKeyToProducerMap, _buildMap;
      producers = [];
      subscriptionKeyToProducerMap = {};
      ProducerMapper = {
        findProducerClassForSubscription: function(subscriptionKey) {
          var key, producerClass;
          key = subscriptionKey.key;
          producerClass = subscriptionKeyToProducerMap[key];
          if (!(producers.length > 0)) {
            throw "There are no producers registered - register producers through the DataCommunicationManager";
          }
          if (!producerClass) {
            throw "No producer found for subscription " + key + "!";
          }
          return producerClass;
        },
        addProducerClass: function(producerClass) {
          if (producers.indexOf(producerClass) === -1) {
            producers.push(producerClass);
            _buildMap();
          }
          return this;
        },
        removeProducerClass: function(producerClass) {
          var index;
          index = producers.indexOf(producerClass);
          if (index !== -1) {
            producers.splice(index, 1);
            producerClass.prototype.SUBSCRIPTION_KEYS.forEach((function(_this) {
              return function(subscriptionKey) {
                var key;
                key = subscriptionKey.key;
                return delete subscriptionKeyToProducerMap[key];
              };
            })(this));
            _buildMap();
          }
          return this;
        },
        getAllProducers: function() {
          return producers;
        },
        removeAllProducers: function() {
          producers = [];
          return subscriptionKeyToProducerMap = {};
        }
      };
      _buildMap = function() {
        return producers.forEach((function(_this) {
          return function(producer) {
            return producer.prototype.SUBSCRIPTION_KEYS.forEach(function(subscriptionKey) {
              var key;
              key = subscriptionKey.key;
              return subscriptionKeyToProducerMap[key] = producer;
            });
          };
        })(this));
      };
      return Vigor.ProducerMapper = ProducerMapper;
    })();
    (function() {
      var ProducerManager, instansiatedProducers, producerMapper, _instansiateProducer;
      producerMapper = Vigor.ProducerMapper;
      instansiatedProducers = {};
      ProducerManager = {
        addProducersToMap: function(producers) {
          var producerClass, _i, _len, _results;
          if (_.isArray(producers)) {
            _results = [];
            for (_i = 0, _len = producers.length; _i < _len; _i++) {
              producerClass = producers[_i];
              _results.push(producerMapper.addProducerClass(producerClass));
            }
            return _results;
          } else {
            return producerMapper.addProducerClass(producers);
          }
        },
        removeProducersFromMap: function(producers) {
          var producerClass, _i, _len, _results;
          if (_.isArray(producers)) {
            _results = [];
            for (_i = 0, _len = producers.length; _i < _len; _i++) {
              producerClass = producers[_i];
              _results.push(producerMapper.removeProducerClass(producerClass));
            }
            return _results;
          } else {
            return producerMapper.removeProducerClass(producers);
          }
        },
        removeAllProducersFromMap: function() {
          return producerMapper.removeAllProducers();
        },
        getProducer: function(subscriptionKey) {
          var producerClass;
          producerClass = producerMapper.findProducerClassForSubscription(subscriptionKey);
          return _instansiateProducer(producerClass);
        },
        getProducerInstanceByName: function(name) {
          return instansiatedProducers[name];
        },
        removeProducer: function(subscriptionKey) {
          var producer, producerClass;
          producerClass = producerMapper.findProducerClassForSubscription(subscriptionKey);
          producer = instansiatedProducers[producerClass.prototype.NAME];
          if (producer) {
            producer.dispose();
            return delete instansiatedProducers[producerClass.prototype.NAME];
          }
        },
        addComponentToProducer: function(subscriptionKey, componentIdentifier) {
          var producer;
          producer = this.getProducer(subscriptionKey);
          return producer.addComponent(subscriptionKey, componentIdentifier);
        },
        subscribe: function(subscriptionKey, options) {
          var producer, producerClass;
          producerClass = producerMapper.findProducerClassForSubscription(subscriptionKey);
          producer = _instansiateProducer(producerClass);
          return producer.subscribe(subscriptionKey, options);
        }
      };
      _instansiateProducer = function(producerClass) {
        var producer;
        if (!instansiatedProducers[producerClass.prototype.NAME]) {
          producer = new producerClass();
          instansiatedProducers[producerClass.prototype.NAME] = producer;
        }
        return instansiatedProducers[producerClass.prototype.NAME];
      };
      return Vigor.ProducerManager = ProducerManager;
    })();
    (function() {
      var APIService, ServiceChannel;
      ServiceChannel = (function() {
        ServiceChannel.prototype.subscribers = void 0;

        ServiceChannel.prototype.pollingInterval = void 0;

        ServiceChannel.prototype.lastPollTime = void 0;

        ServiceChannel.prototype.timeout = void 0;

        ServiceChannel.prototype.name = void 0;

        function ServiceChannel(_window, name, service, subscribers) {
          this._window = _window;
          this.name = name;
          this.service = service;
          this.subscribers = subscribers;
          this.params = this.getParams();
          this.restart();
        }

        ServiceChannel.prototype.restart = function() {
          var elapsedWait, wait;
          this.pollingInterval = this.getPollingInterval();
          if (this.lastPollTime != null) {
            elapsedWait = this._window.Date.now() - this.lastPollTime;
            wait = this.pollingInterval - elapsedWait;
            if (wait < 0) {
              wait = 0;
            }
          } else {
            wait = 0;
          }
          return this.setupNextFetch(wait);
        };

        ServiceChannel.prototype.stop = function() {
          this._window.clearTimeout(this.timeout);
          this.timeout = void 0;
          this.subscribers = void 0;
          this.params = void 0;
          return this.service.removeChannel(this);
        };

        ServiceChannel.prototype.setupNextFetch = function(wait) {
          if (wait == null) {
            wait = this.pollingInterval;
          }
          this._window.clearTimeout(this.timeout);
          return this.timeout = this._window.setTimeout(_.bind(function() {
            this.lastPollTime = this._window.Date.now();
            this.service.fetch(this.params);
            this.cullImmediateRequests();
            if (this.subscribers != null) {
              if (this.pollingInterval > 0) {
                return this.setupNextFetch();
              } else {
                return this.timeout = void 0;
              }
            }
          }, this), wait);
        };

        ServiceChannel.prototype.addSubscription = function(subscriber) {
          if (!_.contains(this.subscribers, subscriber)) {
            this.subscribers.push(subscriber);
            return this.onSubscriptionsChanged();
          }
        };

        ServiceChannel.prototype.removeSubscription = function(subscriber) {
          if (_.contains(this.subscribers, subscriber)) {
            this.subscribers = _.without(this.subscribers, subscriber);
            if (this.subscribers.length === 0) {
              return this.stop();
            } else {
              return this.onSubscriptionsChanged();
            }
          }
        };

        ServiceChannel.prototype.onSubscriptionsChanged = function() {
          var didParamsChange, oldParams, params, shouldFetchImmediately;
          params = this.getParams();
          didParamsChange = !_.isEqual(params, this.params);
          oldParams = this.params;
          this.params = params;
          shouldFetchImmediately = false;
          if (didParamsChange) {
            shouldFetchImmediately = this.service.shouldFetchOnParamsUpdate(this.params, oldParams, this.name);
          }
          if (shouldFetchImmediately) {
            this.lastPollTime = void 0;
            return this.restart();
          } else if (this.getPollingInterval() !== this.pollingInterval) {
            return this.restart();
          }
        };

        ServiceChannel.prototype.getPollingInterval = function() {
          var pollingInterval;
          pollingInterval = _.min(_.map(this.subscribers, function(subscriber) {
            return subscriber.pollingInterval;
          }));
          if (pollingInterval === Infinity) {
            return 0;
          } else {
            return pollingInterval;
          }
        };

        ServiceChannel.prototype.getParams = function() {
          return this.service.consolidateParams(_.filter(_.map(this.subscribers, function(subscriber) {
            return subscriber.params;
          })), this.name);
        };

        ServiceChannel.prototype.cullImmediateRequests = function() {
          var immediateRequests;
          immediateRequests = _.filter(this.subscribers, function(subscriber) {
            return (subscriber.pollingInterval === void 0) || (subscriber.pollingInterval === 0);
          });
          _.each(immediateRequests, function(immediateRequest) {
            return this.removeSubscription(immediateRequest);
          }, this);
          return this.pollingInterval = this.getPollingInterval();
        };

        return ServiceChannel;

      })();
      APIService = (function() {
        APIService.prototype.consolidateParams = function(paramsArray, channelName) {
          return paramsArray[0];
        };

        APIService.prototype.channelForParams = function(params) {
          return (JSON.stringify(params)) || "{}";
        };

        APIService.prototype.shouldFetchOnParamsUpdate = function(newParams, oldParams, channelName) {
          return true;
        };

        APIService.prototype.onFetchSuccess = function() {};

        APIService.prototype.onFetchError = function() {};

        APIService.prototype.onPostSuccess = function() {};

        APIService.prototype.onPostError = function() {};

        APIService.prototype.sync = function(method, model, options) {
          return Backbone.Model.prototype.sync.call(model, method, model, options);
        };

        APIService.prototype.url = function(model) {
          return Backbone.Model.prototype.url.call(model);
        };

        APIService.prototype.parse = function(resp, options, model) {
          return Backbone.Model.prototype.parse.call(model);
        };

        APIService.prototype.channels = void 0;

        function APIService(_window) {
          var service;
          this._window = _window != null ? _window : window;
          this.channels = {};
          service = this;
          this.Model = Backbone.Model.extend({
            sync: function(method, model, options) {
              return service.sync(method, model, options);
            },
            url: function() {
              return service.url(this);
            },
            parse: function(resp, options) {
              return service.parse(resp, options, this);
            }
          });
        }

        APIService.prototype.removeChannel = function(channel) {
          return this.channels = _.without(this.channels, channel);
        };

        APIService.prototype.addSubscription = function(subscriber) {
          var method;
          method = subscriber.method || 'GET';
          switch (method) {
            case 'GET':
              return this.addGetSubscription(subscriber);
            case 'POST':
              return this.post(subscriber.postParams);
            case 'PUT':
              throw 'PUT not yet implemented';
              break;
            case 'DELETE':
              throw 'DELETE not yet implemented';
          }
        };

        APIService.prototype.addGetSubscription = function(subscriber) {
          var channel, channelName;
          channelName = this.channelForParams(subscriber.params);
          channel = this.channels[channelName];
          if (channel != null) {
            return channel.addSubscription(subscriber);
          } else {
            return this.channels[channelName] = new ServiceChannel(this._window, channelName, this, [subscriber]);
          }
        };

        APIService.prototype.removeSubscription = function(subscriber) {
          var channel, channelId;
          if (subscriber != null) {
            channelId = this.channelForParams(subscriber.params);
            channel = this.channels[channelId];
            if (channel != null) {
              return channel.removeSubscription(subscriber);
            }
          }
        };

        APIService.prototype.getModelInstance = function(params) {
          return new this.Model(params);
        };

        APIService.prototype.propagateResponse = function(key, responseData) {
          return this.trigger(key, responseData);
        };

        APIService.prototype.fetch = function(params) {
          var model;
          model = this.getModelInstance(params);
          return model.fetch({
            success: this.onFetchSuccess,
            error: this.onFetchError
          });
        };

        APIService.prototype.post = function(params) {
          var model;
          model = this.getModelInstance(params);
          return model.save(void 0, {
            success: this.onPostSuccess,
            error: this.onPostError
          });
        };

        return APIService;

      })();
      _.extend(APIService.prototype, Backbone.Events);
      APIService.extend = Vigor.extend;
      return Vigor.APIService = APIService;
    })();
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
    (function() {
      var DataCommunicationManager, producerManager, subscriptionsWithComponentIdentifiers, subscriptionsWithProducers, _addComponentToSubscription, _createSubscription, _isSubscriptionValid, _removeComponentFromSubscription, _removeSubscription;
      ComponentIdentifier = Vigor.ComponentIdentifier;
      producerManager = Vigor.ProducerManager;
      subscriptionsWithComponentIdentifiers = {};
      subscriptionsWithProducers = {};
      DataCommunicationManager = {
        registerProducers: function(producers) {
          return producerManager.addProducersToMap(producers);
        },
        unregisterProducers: function(producers) {
          return producerManager.removeProducersFromMap(producers);
        },
        unregisterAllProducers: function() {
          return producerManager.removeAllProducersFromMap();
        },
        subscribe: function(componentId, subscriptionKey, subscriptionCb, subscriptionOptions) {
          var componentIdentifier, keys;
          if (subscriptionOptions == null) {
            subscriptionOptions = {};
          }
          componentIdentifier = new ComponentIdentifier(componentId, subscriptionCb, subscriptionOptions);
          keys = _.keys(subscriptionsWithComponentIdentifiers);
          if (_.indexOf(keys, subscriptionKey.key) === -1) {
            _createSubscription(subscriptionKey);
          }
          _addComponentToSubscription(subscriptionKey, componentIdentifier);
          return producerManager.subscribe(subscriptionKey, subscriptionOptions);
        },
        unsubscribe: function(componentId, subscriptionKey) {
          return _removeComponentFromSubscription(subscriptionKey, componentId);
        },
        unsubscribeAll: function(componentId) {
          var keys, len, _results;
          keys = _.keys(subscriptionsWithComponentIdentifiers);
          len = keys.length;
          _results = [];
          while (len--) {
            _results.push(_removeComponentFromSubscription(keys[len], componentId));
          }
          return _results;
        },
        getSubscriptionsWithSubscriptionKey: function(subscriptionKey) {
          var key;
          key = subscriptionKey.key;
          return subscriptionsWithComponentIdentifiers[key];
        },
        reset: function() {
          subscriptionsWithComponentIdentifiers = {};
          return subscriptionsWithProducers = {};
        }
      };
      _createSubscription = function(subscriptionKey) {
        var key, producer;
        key = subscriptionKey.key;
        subscriptionsWithComponentIdentifiers[key] = [];
        producer = producerManager.getProducer(subscriptionKey);
        return subscriptionsWithProducers[key] = producer;
      };
      _removeSubscription = function(subscriptionKey) {
        var key;
        key = subscriptionKey.key;
        delete subscriptionsWithComponentIdentifiers[key];
        delete subscriptionsWithProducers[key];
        return producerManager.removeProducer(subscriptionKey);
      };
      _addComponentToSubscription = function(subscriptionKey, componentIdentifier) {
        var existingComponent, key, subscriptionComponents;
        key = subscriptionKey.key;
        subscriptionComponents = subscriptionsWithComponentIdentifiers[key];
        existingComponent = _.find(subscriptionComponents, function(component) {
          return component.id === componentIdentifier.id;
        });
        if (!existingComponent) {
          subscriptionComponents.push(componentIdentifier);
          return producerManager.addComponentToProducer(subscriptionKey, componentIdentifier);
        }
      };
      _removeComponentFromSubscription = function(subscriptionKey, componentId) {
        var component, componentIndex, components, index, key, _i, _len;
        key = subscriptionKey.key;
        components = subscriptionsWithComponentIdentifiers[key];
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
        if (!_isSubscriptionValid(subscriptionKey)) {
          return _removeSubscription(subscriptionKey);
        }
      };
      _isSubscriptionValid = function(subscriptionKey) {
        var componentIdentifiers, key;
        key = subscriptionKey.key;
        componentIdentifiers = subscriptionsWithComponentIdentifiers[key];
        if (_.isEmpty(componentIdentifiers)) {
          return false;
        } else {
          return true;
        }
      };
      return Vigor.DataCommunicationManager = DataCommunicationManager;
    })();
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
      var DataCommunicationManager;

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

      ViewModel.prototype.validateContract = function(contract, incommingData) {
        var contractKeyCount, dataKeyCount, key, val;
        if (!contract) {
          throw new Error("The " + this.id + " does not have any contract specified");
          return false;
        }
        if (!incommingData) {
          throw new Error("" + this.id + "'s callback for subscribe is called but it does not recieve any data");
          return false;
        }
        if (_.isArray(contract) && _.isArray(incommingData) === false) {
          console.warn("" + this.id + " is supposed to recieve an array but is recieving " + (typeof incommingData));
        }
        if (_.isObject(contract) && _.isArray(contract) === false && _.isArray(incommingData)) {
          console.warn("" + this.id + " is supposed to recieve an object but is recieving an array");
        }
        if (_.isObject(contract) && _.isArray(contract) === false) {
          contractKeyCount = _.keys(contract).length;
          dataKeyCount = _.keys(incommingData).length;
          if (dataKeyCount > contractKeyCount) {
            console.warn("" + this.id + " is recieving more data then what is specified in the contract", contract, incommingData);
          } else if (dataKeyCount < contractKeyCount) {
            console.warn("" + this.id + " is recieving less data then what is specified in the contract", contract, incommingData);
          }
        }
        for (key in contract) {
          val = contract[key];
          if (val != null) {
            if (typeof incommingData[key] !== typeof val) {
              console.warn("" + this.id + " is recieving data of the wrong type according to the contract, " + key + ", expects " + (typeof val) + " but gets " + (typeof incommingData[key]));
            }
          }
          if (!(key in incommingData)) {
            console.warn("" + this.id + " recieving data but is missing the key: " + key);
          }
        }
        return true;
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

      ServiceRepository.prototype.services = {};

      ServiceRepository.prototype.addSubscription = function(type, subscription) {
        if (this.services[type]) {
          return this.services[type].addSubscription(subscription);
        }
      };

      ServiceRepository.prototype.removeSubscription = function(type, subscription) {
        if (this.services[type]) {
          return this.services[type].removeSubscription(subscription);
        }
      };

      return ServiceRepository;

    })(Vigor.Repository);
    Vigor.ServiceRepository = ServiceRepository;
    return Vigor;
  });

}).call(this);
