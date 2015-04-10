(function() {
  var indexOf = [].indexOf || function(item) { for (var i = 0, l = this.length; i < l; i++) { if (i in this && this[i] === item) return i; } return -1; },
    extend = function(child, parent) { for (var key in parent) { if (hasProp.call(parent, key)) child[key] = parent[key]; } function ctor() { this.constructor = child; } ctor.prototype = parent.prototype; child.prototype = new ctor(); child.__super__ = parent.prototype; return child; },
    hasProp = {}.hasOwnProperty,
    bind = function(fn, me){ return function(){ return fn.apply(me, arguments); }; },
    slice = [].slice;

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
    var ComponentIdentifier, ComponentView, EventBus, EventRegistry, PackageBase, Producer, Repository, ServiceRepository, ViewModel, Vigor, previousVigor, setup, validateContract;
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
    Producer = (function() {
      Producer.prototype.PRODUCTION_KEY = void 0;

      Producer.prototype._isSubscribedToRepositories = false;

      function Producer() {
        this.registeredComponents = {};
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
        var subscription;
        subscription = this.registeredComponents[componentId];
        if (subscription != null) {
          this.unsubscribe(subscription.options);
          delete this.registeredComponents[subscription.id];
          if (this.shouldUnsubscribeFromRepositories()) {
            this.unsubscribeFromRepositories();
            return this._isSubscribedToRepositories = false;
          }
        }
      };

      Producer.prototype.produce = function(data, filterFn) {
        var component, componentsInterestedInChange, i, len, results, type;
        if (filterFn == null) {
          filterFn = function() {};
        }
        type = Object.prototype.toString.call(this).slice(8, -1);
        this._validateContract(data, type);
        componentsInterestedInChange = _.filter(this.registeredComponents, function(componentIdentifier) {
          return _.isEmpty(componentIdentifier.options) || filterFn(componentIdentifier.options);
        });
        results = [];
        for (i = 0, len = componentsInterestedInChange.length; i < len; i++) {
          component = componentsInterestedInChange[i];
          results.push(component.callback(data));
        }
        return results;
      };

      Producer.prototype.subscribe = function(options) {
        throw new Error("Subscription handler should be overriden in subclass! Implement for subscription " + subscriptionKey + " with options " + options);
      };

      Producer.prototype.unsubscribe = function(options) {};

      Producer.prototype.subscribeToRepositories = function() {
        throw 'subscribeToRepositories should be overridden in subclass!';
      };

      Producer.prototype.unsubscribeFromRepositories = function() {
        throw 'unsubscribeFromRepositories should be overridden in subclass!';
      };

      Producer.prototype.shouldUnsubscribeFromRepositories = function() {
        var component;
        for (component in this.registeredComponents) {
          return false;
        }
        return true;
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
        var decorator, i, len;
        for (i = 0, len = decoratorList.length; i < len; i++) {
          decorator = decoratorList[i];
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

      return Producer;

    })();
    Producer.extend = Vigor.extend;
    Vigor.Producer = Producer;
    (function() {
      var NO_PRODUCERS_ERROR, NO_PRODUCER_FOUND_ERROR, ProducerMapper, producers, producersByKey;
      producers = [];
      producersByKey = {};
      NO_PRODUCERS_ERROR = "There are no producers registered - register producers through the DataCommunicationManager";
      NO_PRODUCER_FOUND_ERROR = function(key) {
        return "No producer found for subscription " + key + "!";
      };
      ProducerMapper = {
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
            return producersByKey[key] = producerClass;
          }
        },
        reset: function() {
          producers = [];
          return producersByKey = {};
        }
      };
      return Vigor.ProducerMapper = ProducerMapper;
    })();
    (function() {
      var ProducerManager, producerMapper;
      producerMapper = Vigor.ProducerMapper;
      ProducerManager = {
        registerProducers: function(producers) {
          return producers.forEach(function(producer) {
            return producerMapper.register(producer);
          });
        },
        producerForKey: function(subscriptionKey) {
          var producer;
          return producer = producerMapper.producerForKey(subscriptionKey);
        },
        subscribeComponentToKey: function(subscriptionKey, subscription) {
          var producer;
          producer = this.producerForKey(subscriptionKey);
          return producer.addComponent(subscription);
        },
        unsubscribeComponentFromKey: function(subscriptionKey, componentId) {
          var producer;
          producer = this.producerForKey(subscriptionKey);
          return producer.removeComponent(componentId);
        },
        unsubscribeComponent: function(componentId) {
          return producerMapper.producers.forEach(function(producer) {
            return producer.prototype.getInstance().removeComponent(componentId);
          });
        }
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

        APIService.prototype.channels = void 0;

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
    ComponentIdentifier = (function() {
      ComponentIdentifier.prototype.id = void 0;

      ComponentIdentifier.prototype.callback = void 0;

      ComponentIdentifier.prototype.options = void 0;

      function ComponentIdentifier(id1, callback1, options1) {
        this.id = id1;
        this.callback = callback1;
        this.options = options1;
      }

      return ComponentIdentifier;

    })();
    Vigor.ComponentIdentifier = ComponentIdentifier;
    (function() {
      var DataCommunicationManager, Subscription, producerManager;
      Subscription = Vigor.ComponentIdentifier;
      producerManager = Vigor.ProducerManager;
      DataCommunicationManager = {
        registerProducers: function(producers) {
          return producerManager.registerProducers(producers);
        },
        subscribe: function(componentId, subscriptionKey, callback, subscriptionOptions) {
          var subscription;
          if (subscriptionOptions == null) {
            subscriptionOptions = {};
          }
          subscription = new Subscription(componentId, callback, subscriptionOptions);
          return producerManager.subscribeComponentToKey(subscriptionKey, subscription);
        },
        unsubscribe: function(componentId, subscriptionKey) {
          return producerManager.unsubscribeComponentFromKey(subscriptionKey, componentId);
        },
        unsubscribeAll: function(componentId) {
          return producerManager.unsubscribeComponent(componentId);
        }
      };
      return Vigor.DataCommunicationManager = DataCommunicationManager;
    })();
    ComponentView = (function(superClass) {
      extend(ComponentView, superClass);

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
    ViewModel = (function() {
      var dataCommunicationManager;

      dataCommunicationManager = Vigor.DataCommunicationManager;

      function ViewModel() {
        this.id = "ViewModel_" + (_.uniqueId());
      }

      ViewModel.prototype.dispose = function() {
        return this.unsubscribeAll();
      };

      ViewModel.prototype.subscribe = function(key, callback, options) {
        return dataCommunicationManager.subscribe(this.id, key, callback, options);
      };

      ViewModel.prototype.unsubscribe = function(key) {
        return dataCommunicationManager.unsubscribe(this.id, key);
      };

      ViewModel.prototype.unsubscribeAll = function() {
        return dataCommunicationManager.unsubscribeAll(this.id);
      };

      ViewModel.prototype.validateContract = function(contract, incommingData) {
        return Vigor.helpers.validateContract(contract, incommingData, this.id);
      };

      return ViewModel;

    })();
    ViewModel.extend = Vigor.extend;
    Vigor.ViewModel = ViewModel;
    Repository = (function(superClass) {
      extend(Repository, superClass);

      function Repository() {
        this._debounced = bind(this._debounced, this);
        this._onRemove = bind(this._onRemove, this);
        this._onChange = bind(this._onChange, this);
        this._onAdd = bind(this._onAdd, this);
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
