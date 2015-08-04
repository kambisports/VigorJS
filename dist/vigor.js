/**
 * vigorjs - A small framework for structuring large scale Backbone applications
 * @version v0.0.5
 * @link 
 * @license ISC
 */
(function() {
  var indexOf = [].indexOf || function(item) { for (var i = 0, l = this.length; i < l; i++) { if (i in this && this[i] === item) return i; } return -1; },
    bind = function(fn, me){ return function(){ return fn.apply(me, arguments); }; },
    extend = function(child, parent) { for (var key in parent) { if (hasProp.call(parent, key)) child[key] = parent[key]; } function ctor() { this.constructor = child; } ctor.prototype = parent.prototype; child.prototype = new ctor(); child.__super__ = parent.prototype; return child; },
    hasProp = {}.hasOwnProperty,
    slice = [].slice;

  (function(root, factory) {
    var $, Backbone, _;
    if (typeof define === "function" && define.amd) {
      define(['backbone', 'underscore', 'jquery'], function(Backbone, _, $) {
        return factory(root, Backbone, _, $);
      });
    } else if (typeof exports === "object") {
      Backbone = require('backbone');
      _ = require('underscore');
      $ = require('jquery');
      module.exports = factory(root, Backbone, _, $);
    } else {
      root.Vigor = factory(root, root.Backbone, root._, root.$);
    }
  })(this, function(root, Backbone, _, $) {
    var ComponentBase, ComponentView, ComponentViewModel, EventBus, EventRegistry, IdProducer, KEY_ALREADY_REGISTERED, NO_PRODUCERS_ERROR, NO_PRODUCER_FOUND_ERROR, Producer, Repository, ServiceRepository, Subscription, Vigor, previousVigor, producerManager, producerMapper, producers, producersByKey, setup, validateContract;
    previousVigor = root.Vigor;
    Vigor = Backbone.Vigor = {};
    Vigor.helpers = {};
    Vigor.settings = {};
    Vigor.noConflict = function() {
      return root.Vigor = previousVigor;
    };
    Vigor.extend = Backbone.Model.extend;
    Vigor.settings = {
      validateContract: false
    };
    setup = function(configObj) {
      var settings;
      settings = {};
      settings.validateContract = configObj.validateContract || false;
      return _.extend(Vigor.settings, settings);
    };
    Vigor.setup = setup;
    validateContract = function(contract, dataToCompare, comparatorId, verb) {
      var contractKeyCount, dataKeyCount, key, val;
      if (verb == null) {
        verb = 'recieving';
      }
      if (!Vigor.settings.validateContract) {
        return;
      }
      if (!contract) {
        throw new Error("The " + comparatorId + " does not have any contract specified");
        return false;
      }
      if (!dataToCompare) {
        throw new Error(comparatorId + " is trying to validate the contract but does not recieve any data to compare against the contract");
        return false;
      }
      if (_.isArray(contract) && _.isArray(dataToCompare) === false) {
        throw new Error(comparatorId + "'s compared data is supposed to be an array but is a " + (typeof dataToCompare));
        return false;
      }
      if (_.isObject(contract) && _.isArray(contract) === false && _.isArray(dataToCompare)) {
        throw new Error(comparatorId + "'s compared data is supposed to be an object but is an array");
        return false;
      }
      if (_.isObject(contract) && _.isArray(contract) === false) {
        contractKeyCount = _.keys(contract).length;
        dataKeyCount = _.keys(dataToCompare).length;
        if (dataKeyCount > contractKeyCount) {
          throw new Error(comparatorId + " is " + verb + " more data then what is specified in the contract", contract, dataToCompare);
          return false;
        } else if (dataKeyCount < contractKeyCount) {
          throw new Error(comparatorId + " is " + verb + " less data then what is specified in the contract", contract, dataToCompare);
          return false;
        }
      }
      for (key in contract) {
        val = contract[key];
        if (!(key in dataToCompare)) {
          throw new Error(comparatorId + " has data but is missing the key: " + key);
          return false;
        }
        if (val != null) {
          if (typeof dataToCompare[key] !== typeof val) {
            throw new Error(comparatorId + " is " + verb + " data of the wrong type according to the contract, " + key + ", expects " + (typeof val) + " but gets " + (typeof dataToCompare[key]));
            return false;
          }
        }
      }
      return true;
    };
    Vigor.helpers.validateContract = validateContract;
    EventRegistry = (function() {
      function EventRegistry() {}

      return EventRegistry;

    })();
    _.extend(EventRegistry.prototype, Backbone.Events);
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
        return indexOf.call((function() {
          var ref, results;
          ref = Vigor.EventKeys;
          results = [];
          for (property in ref) {
            value = ref[property];
            results.push(value);
          }
          return results;
        })(), key) >= 0;
      };

      return EventBus;

    })();
    Vigor.EventBus = new EventBus();
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
    Subscription = (function() {
      Subscription.prototype.id = void 0;

      Subscription.prototype.callback = void 0;

      Subscription.prototype.options = void 0;

      function Subscription(id1, callback1, options1) {
        this.id = id1;
        this.callback = callback1;
        this.options = options1;
      }

      return Subscription;

    })();

    producers = [];
    producersByKey = {};
    NO_PRODUCERS_ERROR = "There are no producers registered - register producers through the ProducerManager";
    NO_PRODUCER_FOUND_ERROR = function(key) {
      return "No producer found for subscription " + key + "!";
    };
    KEY_ALREADY_REGISTERED = function(key) {
      return "A producer for the key " + key + " is already registered";
    };
    producerMapper = {
      producers: producers,
      producerClassForKey: function(subscriptionKey) {
        var key, producerClass;
        key = subscriptionKey.key;
        if (producers.length === 0) {
          throw NO_PRODUCERS_ERROR;
        }
        producerClass = producersByKey[key];
        if (!producerClass) {
          throw NO_PRODUCER_FOUND_ERROR(key);
        }
        return producerClass;
      },
      producerForKey: function(subscriptionKey) {
        var producerClass;
        producerClass = this.producerClassForKey(subscriptionKey);
        return producerClass.prototype.getInstance();
      },
      register: function(producerClass) {
        var key, subscriptionKey;
        if ((producers.indexOf(producerClass)) === -1) {
          producers.push(producerClass);
          subscriptionKey = producerClass.prototype.PRODUCTION_KEY;
          key = subscriptionKey.key;
          if (producersByKey[key] != null) {
            throw KEY_ALREADY_REGISTERED(key);
          }
          return producersByKey[key] = producerClass;
        }
      },
      reset: function() {
        producers.length = 0;
        return producersByKey = {};
      }
    };

    producerManager = {
      registerProducers: function(producers) {
        return producers.forEach(function(producer) {
          return producerMapper.register(producer);
        });
      },
      producerForKey: function(subscriptionKey) {
        var producer;
        return producer = producerMapper.producerForKey(subscriptionKey);
      },
      subscribe: function(componentId, subscriptionKey, callback, subscriptionOptions) {
        var producer, subscription;
        if (subscriptionOptions == null) {
          subscriptionOptions = {};
        }
        subscription = new Subscription(componentId, callback, subscriptionOptions);
        producer = this.producerForKey(subscriptionKey);
        return producer.addComponent(subscription);
      },
      unsubscribe: function(componentId, subscriptionKey) {
        var producer;
        producer = this.producerForKey(subscriptionKey);
        return producer.removeComponent(componentId);
      },
      unsubscribeAll: function(componentId) {
        return producerMapper.producers.forEach(function(producer) {
          return producer.prototype.getInstance().removeComponent(componentId);
        });
      }
    };
    Vigor.ProducerManager = producerManager;
    Producer = (function() {
      Producer.prototype.PRODUCTION_KEY = void 0;

      Producer.prototype.repositories = [];

      Producer.prototype.decorators = [];

      Producer.prototype._isSubscribedToRepositories = false;

      function Producer() {
        this.onDiffInRepository = bind(this.onDiffInRepository, this);
        this.registeredComponents = {};
        this.produceData = _.throttle(this.produceDataSync, 100);
      }

      Producer.prototype.getInstance = function() {
        if (this.instance == null) {
          this.instance = new this.constructor();
        }
        return this.instance;
      };

      Producer.prototype.addComponent = function(subscription) {
        var existingSubscription;
        existingSubscription = this.registeredComponents[subscription.id];
        if (existingSubscription == null) {
          this.registeredComponents[subscription.id] = subscription;
          this.subscribe(subscription.options);
          if (!this._isSubscribedToRepositories) {
            this.subscribeToRepositories();
            return this._isSubscribedToRepositories = true;
          }
        }
      };

      Producer.prototype.removeComponent = function(componentId) {
        var component, shouldUnsubscribe, subscription;
        subscription = this.registeredComponents[componentId];
        if (subscription != null) {
          this.unsubscribe(subscription.options);
          delete this.registeredComponents[subscription.id];
          shouldUnsubscribe = true;
          for (component in this.registeredComponents) {
            shouldUnsubscribe = false;
            break;
          }
          if (shouldUnsubscribe) {
            this.unsubscribeFromRepositories();
            return this._isSubscribedToRepositories = false;
          }
        }
      };

      Producer.prototype.subscribeToRepositories = function() {
        var i, len, ref, repository, results;
        ref = this.repositories;
        results = [];
        for (i = 0, len = ref.length; i < len; i++) {
          repository = ref[i];
          if (repository instanceof Vigor.Repository) {
            results.push(this.subscribeToRepository(repository));
          } else if (repository.repository instanceof Vigor.Repository && typeof repository.callback === 'string') {
            results.push(this.subscribeToRepository(repository.repository, this[repository.callback]));
          } else {
            throw 'unexpected format of producer repositories definition';
          }
        }
        return results;
      };

      Producer.prototype.unsubscribeFromRepositories = function() {
        var i, len, ref, repository;
        ref = this.repositories;
        for (i = 0, len = ref.length; i < len; i++) {
          repository = ref[i];
          if (repository instanceof Vigor.Repository) {
            this.unsubscribeFromRepository(repository);
          } else if (repository.repository instanceof Vigor.Repository && typeof repository.callback === 'string') {
            this.unsubscribeFromRepository(repository.repository);
          }
        }
        return void 0;
      };

      Producer.prototype.subscribeToRepository = function(repository, callback) {
        callback = callback || (function(_this) {
          return function(diff) {
            return _this.onDiffInRepository(repository, diff);
          };
        })(this);
        return this.listenTo(repository, Vigor.Repository.prototype.REPOSITORY_DIFF, callback);
      };

      Producer.prototype.unsubscribeFromRepository = function(repository) {
        return this.stopListening(repository, Vigor.Repository.prototype.REPOSITORY_DIFF);
      };

      Producer.prototype.subscribe = function() {
        return this.produceDataSync();
      };

      Producer.prototype.onDiffInRepository = function() {
        return this.produceData();
      };

      Producer.prototype.produceDataSync = function() {
        return this.produce(this.currentData());
      };

      Producer.prototype.produce = function(data) {
        var component, componentId, ref, results;
        data = this.decorate(data);
        this._validateContract(data);
        ref = this.registeredComponents;
        results = [];
        for (componentId in ref) {
          component = ref[componentId];
          results.push(component.callback(data));
        }
        return results;
      };

      Producer.prototype.currentData = function() {};

      Producer.prototype.unsubscribe = function(options) {};

      Producer.prototype.decorate = function(data) {
        var decorator, i, len, ref;
        ref = this.decorators;
        for (i = 0, len = ref.length; i < len; i++) {
          decorator = ref[i];
          decorator(data);
        }
        return data;
      };

      Producer.prototype.modelToJSON = function(model) {
        return model.toJSON();
      };

      Producer.prototype.modelsToJSON = function(models) {
        return _.map(models, this.modelToJSON);
      };

      Producer.prototype._validateContract = function(dataToProduce) {
        var contract;
        contract = this.PRODUCTION_KEY.contract;
        if (!contract) {
          throw new Error("The subscriptionKey " + subscriptionKey.key + " doesn't have a contract specified");
        }
        return Vigor.helpers.validateContract(contract, dataToProduce, this, 'producing');
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

      return Producer;

    })();
    _.extend(Producer.prototype, Backbone.Events);
    Producer.extend = Vigor.extend;
    Vigor.Producer = Producer;
    IdProducer = (function(superClass) {
      extend(IdProducer, superClass);

      IdProducer.prototype.updatedIds = void 0;

      IdProducer.prototype.subscriptions = void 0;

      IdProducer.prototype.idType = typeof 0;

      function IdProducer() {
        IdProducer.__super__.constructor.apply(this, arguments);
        this.updatedIds = [];
        this.subscriptions = {};
      }

      IdProducer.prototype.subscribe = function(options) {
        var id;
        id = this.idForOptions(options);
        if (typeof id !== this.idType) {
          throw "expected the subscription key to be a " + this.idType + " but got a " + (typeof subscriptionKey);
        }
        if (this.subscriptions[id]) {
          this.subscriptions[id].push(options);
        } else {
          this.subscriptions[id] = [options];
        }
        return this.produceDataSync(id);
      };

      IdProducer.prototype.onDiffInRepository = function(repository, diff) {
        var addRemoveMap, addedModelIds, changeMap, removedModelIds, self, updatedModelIds;
        self = this;
        addRemoveMap = function(model) {
          var id;
          id = self.idForModel(model, repository);
          if (_.isArray(id)) {
            return _.filter(id, self.hasId.bind(self));
          } else if (self.hasId(id)) {
            return id;
          }
        };
        changeMap = function(model) {
          var id;
          id = self.idForModel(model, repository);
          if (self.shouldPropagateModelChange(model, repository)) {
            if (_.isArray(id)) {
              return _.filter(id, self.hasId.bind(self));
            } else if (self.hasId(id)) {
              return id;
            }
          }
        };
        addedModelIds = _.map(diff.added, addRemoveMap);
        removedModelIds = _.map(diff.removed, addRemoveMap);
        updatedModelIds = _.map(diff.changed, changeMap);
        return this.produceDataForIds(_.filter(_.flatten([addedModelIds, removedModelIds, updatedModelIds])));
      };

      IdProducer.prototype.produceDataForIds = function(ids) {
        if (ids == null) {
          ids = this.allIds();
        }
        this.updatedIds = _.uniq(this.updatedIds.concat(ids));
        return this.produceData();
      };

      IdProducer.prototype.allIds = function() {
        var ids;
        ids = _.keys(this.subscriptions);
        if (this.idType === (typeof 0)) {
          ids = _.map(ids, function(id) {
            return parseInt(id, 10);
          });
        }
        return ids;
      };

      IdProducer.prototype.produceDataSync = function(id) {
        var ids;
        if (id != null) {
          return this.produce([id]);
        } else if (this.updatedIds.length > 0) {
          ids = this.updatedIds.slice();
          this.updatedIds.length = 0;
          return this.produce(ids);
        }
      };

      IdProducer.prototype.unsubscribe = function(options) {
        var id, index, subscription;
        id = this.idForOptions(options);
        subscription = this.subscriptions[id];
        if (subscription != null) {
          index = subscription.indexOf(options);
          if (index !== -1) {
            subscription.splice(index, 1);
            if (subscription.length === 0) {
              return delete this.subscriptions[id];
            }
          }
        }
      };

      IdProducer.prototype.produce = function(ids) {
        var data, i, id, len, results;
        results = [];
        for (i = 0, len = ids.length; i < len; i++) {
          id = ids[i];
          data = this.currentData(id) || {};
          data.id = id;
          data = this.decorate(data);
          this._validateContract(data);
          results.push(_.each(this.registeredComponents, function(component) {
            if (id === this.idForOptions(component.options)) {
              return component.callback(data);
            }
          }, this));
        }
        return results;
      };

      IdProducer.prototype.currentData = function(id) {};

      IdProducer.prototype.hasId = function(id) {
        return this.subscriptions[id] != null;
      };

      IdProducer.prototype.shouldPropagateModelChange = function(model, repository) {
        return true;
      };

      IdProducer.prototype.idForModel = function(model, repository) {
        return model.id;
      };

      IdProducer.prototype.idForOptions = function(options) {
        return options.id;
      };

      return IdProducer;

    })(Producer);
    Vigor.IdProducer = IdProducer;
    (function() {
      var APIService, ServiceChannel;
      ServiceChannel = (function() {
        ServiceChannel.prototype.subscribers = void 0;

        ServiceChannel.prototype.pollingInterval = void 0;

        ServiceChannel.prototype.lastPollTime = void 0;

        ServiceChannel.prototype.timeout = void 0;

        ServiceChannel.prototype.name = void 0;

        function ServiceChannel(_window, name1, service1, subscribers) {
          this._window = _window;
          this.name = name1;
          this.service = service1;
          this.subscribers = subscribers;
          this.params = this.getParams();
          this.restart();
        }

        ServiceChannel.prototype.restart = function() {
          var elapsedWait, wait;
          this.pollingInterval = this.getPollingInterval();
          if (this.lastPollTime != null) {
            elapsedWait = this._window.Date.now() - this.lastPollTime;
            wait = Math.max(this.pollingInterval - elapsedWait, 0);
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

        APIService.prototype.removeChannel = function(channel) {
          return delete this.channels[channel.name];
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
    ComponentBase = (function() {
      function ComponentBase() {}

      ComponentBase.prototype.render = function() {
        throw 'ComponentBase->render needs to be over-ridden';
      };

      ComponentBase.prototype.dispose = function() {
        throw 'ComponentBase->dispose needs to be over-ridden';
      };

      return ComponentBase;

    })();
    _.extend(ComponentBase.prototype, Backbone.Events);
    ComponentBase.extend = Vigor.extend;
    Vigor.ComponentBase = ComponentBase;
    ComponentView = (function(superClass) {
      extend(ComponentView, superClass);

      ComponentView.prototype.viewModel = void 0;

      function ComponentView() {
        this._checkIfImplemented(['renderStaticContent', 'renderDynamicContent', 'addSubscriptions', 'removeSubscriptions', 'dispose']);
        ComponentView.__super__.constructor.apply(this, arguments);
      }

      ComponentView.prototype.initialize = function(options) {
        ComponentView.__super__.initialize.apply(this, arguments);
        if (options != null ? options.viewModel : void 0) {
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
        var ref;
        if ((ref = this.model) != null) {
          ref.unbind();
        }
        this.removeSubscriptions();
        this.stopListening();
        this.$el.off();
        this.$el.remove();
        return this.off();
      };

      ComponentView.prototype._checkIfImplemented = function(methodNames) {
        var i, len, methodName, results;
        results = [];
        for (i = 0, len = methodNames.length; i < len; i++) {
          methodName = methodNames[i];
          if (!this.constructor.prototype.hasOwnProperty(methodName)) {
            throw new Error(this.constructor.name + " - " + methodName + "() must be implemented in View.");
          } else {
            results.push(void 0);
          }
        }
        return results;
      };

      return ComponentView;

    })(Backbone.View);
    Vigor.ComponentView = ComponentView;
    ComponentViewModel = (function() {
      var ProducerManager;

      ProducerManager = Vigor.ProducerManager;

      function ComponentViewModel() {
        this.id = "ComponentViewModel_" + (_.uniqueId());
      }

      ComponentViewModel.prototype.dispose = function() {
        return this.unsubscribeAll();
      };

      ComponentViewModel.prototype.subscribe = function(key, callback, options) {
        return ProducerManager.subscribe(this.id, key, callback, options);
      };

      ComponentViewModel.prototype.unsubscribe = function(key) {
        return ProducerManager.unsubscribe(this.id, key);
      };

      ComponentViewModel.prototype.unsubscribeAll = function() {
        return ProducerManager.unsubscribeAll(this.id);
      };

      ComponentViewModel.prototype.validateContract = function(contract, incommingData) {
        return Vigor.helpers.validateContract(contract, incommingData, this.id);
      };

      return ComponentViewModel;

    })();
    ComponentViewModel.extend = Vigor.extend;
    Vigor.ComponentViewModel = ComponentViewModel;
    Repository = (function(superClass) {
      extend(Repository, superClass);

      function Repository() {
        this._triggerUpdates = bind(this._triggerUpdates, this);
        this._onRemove = bind(this._onRemove, this);
        this._onChange = bind(this._onChange, this);
        this._onAdd = bind(this._onAdd, this);
        return Repository.__super__.constructor.apply(this, arguments);
      }

      Repository.prototype._throttledAddedModels = void 0;

      Repository.prototype._throttledChangedModels = void 0;

      Repository.prototype._throttledRemovedModels = void 0;

      Repository.prototype._throttledTriggerUpdates = void 0;

      Repository.prototype.initialize = function() {
        this.cid = this.cid || _.uniqueId('c');
        this._throttledAddedModels = {};
        this._throttledChangedModels = {};
        this._throttledRemovedModels = {};
        this._throttledTriggerUpdates = _.throttle(this._triggerUpdates, 100, {
          leading: false
        });
        this.addThrottledListeners();
        return Repository.__super__.initialize.apply(this, arguments);
      };

      Repository.prototype.addThrottledListeners = function() {
        return this.on('all', this._onAll);
      };

      Repository.prototype.getByIds = function(ids) {
        var i, id, len, models;
        models = [];
        for (i = 0, len = ids.length; i < len; i++) {
          id = ids[i];
          models.push(this.get(id));
        }
        return models;
      };

      Repository.prototype.isEmpty = function() {
        return this.models.length <= 0;
      };

      Repository.prototype._onAll = function() {
        var args, event;
        event = arguments[0], args = 2 <= arguments.length ? slice.call(arguments, 1) : [];
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
        return this._throttledTriggerUpdates();
      };

      Repository.prototype._onAdd = function(model) {
        return this._throttledAddedModels[model.id] = model;
      };

      Repository.prototype._onChange = function(model) {
        return this._throttledChangedModels[model.id] = model;
      };

      Repository.prototype._onRemove = function(model) {
        return this._throttledRemovedModels[model.id] = model;
      };

      Repository.prototype._throttledAdd = function() {
        var event, models;
        event = Repository.prototype.REPOSITORY_ADD;
        models = _.values(this._throttledAddedModels);
        this._throttledAddedModels = {};
        return this._throttledEvent(event, models, event);
      };

      Repository.prototype._throttledChange = function() {
        var event, models;
        event = Repository.prototype.REPOSITORY_CHANGE;
        models = _.values(this._throttledChangedModels);
        this._throttledChangedModels = {};
        return this._throttledEvent(event, models, event);
      };

      Repository.prototype._throttledRemove = function() {
        var event, models;
        event = Repository.prototype.REPOSITORY_REMOVE;
        models = _.values(this._throttledRemovedModels);
        this._throttledRemovedModels = {};
        return this._throttledEvent(event, models, event);
      };

      Repository.prototype._throttledEvent = function(event, models, eventRef) {
        if (models.length > 0) {
          this.trigger(event, models, eventRef);
        }
        return models;
      };

      Repository.prototype._throttledDiff = function(added, changed, removed) {
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

      Repository.prototype._triggerUpdates = function() {
        return this._throttledDiff(this._throttledAdd(), this._throttledChange(), this._throttledRemove());
      };

      Repository.prototype.REPOSITORY_DIFF = 'repository_diff';

      Repository.prototype.REPOSITORY_ADD = 'repository_add';

      Repository.prototype.REPOSITORY_CHANGE = 'repository_change';

      Repository.prototype.REPOSITORY_REMOVE = 'repository_remove';

      return Repository;

    })(Backbone.Collection);
    Vigor.Repository = Repository;
    ServiceRepository = (function(superClass) {
      extend(ServiceRepository, superClass);

      function ServiceRepository() {
        return ServiceRepository.__super__.constructor.apply(this, arguments);
      }

      ServiceRepository.prototype.services = {};

      ServiceRepository.prototype.addSubscriptionToService = function(service, subscription) {
        return service.addSubscription(subscription);
      };

      ServiceRepository.prototype.removeSubscriptionFromService = function(service, subscription) {
        return service.removeSubscription(subscription);
      };

      ServiceRepository.prototype.addSubscription = function(type, subscription) {
        if (this.services[type]) {
          return this.addSubscriptionToService(this.services[type], subscription);
        }
      };

      ServiceRepository.prototype.removeSubscription = function(type, subscription) {
        if (this.services[type]) {
          return this.removeSubscriptionFromService(this.services[type], subscription);
        }
      };

      return ServiceRepository;

    })(Vigor.Repository);
    Vigor.ServiceRepository = ServiceRepository;
    return Vigor;
  });

}).call(this);
