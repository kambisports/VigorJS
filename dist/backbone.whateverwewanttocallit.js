(function() {
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

      PackageBase.extend = Backbone.View.extend;

      return PackageBase;

    })();
    Vigor.PackageBase = PackageBase;
    Producer = (function() {
      Producer.prototype.subscriptionKeyToComponents = {};

      function Producer() {
        this._addKeysToMap();
      }

      Producer.prototype.addComponent = function(subscriptionKey, componentIdentifier) {
        var registeredComponents;
        registeredComponents = this.subscriptionKeyToComponents[subscriptionKey];
        if (!registeredComponents) {
          throw new Error('Unknown subscription key, could not add component!');
        }
        return this.subscriptionKeyToComponents[subscriptionKey].push(componentIdentifier);
      };

      Producer.prototype.produce = function(subscriptionKey, data, filterFn) {
        var component, componentsForSubscription, componentsInterestedInChange, _i, _len, _results;
        componentsForSubscription = this.subscriptionKeyToComponents[subscriptionKey];
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

      Producer.extend = Backbone.View.extend;

      Producer.prototype._addKeysToMap = function() {
        var key, _i, _len, _ref, _results;
        _ref = this.SUBSCRIPTION_KEYS;
        _results = [];
        for (_i = 0, _len = _ref.length; _i < _len; _i++) {
          key = _ref[_i];
          _results.push(this.subscriptionKeyToComponents[key] = []);
        }
        return _results;
      };

      Producer.prototype.SUBSCRIPTION_KEYS = [];

      Producer.prototype.NAME = 'Producer';

      return Producer;

    })();
    Vigor.Producer = Producer;
    ProducerMapper = (function() {
      ProducerMapper.prototype.producers = [];

      ProducerMapper.prototype.subscriptionKeyToProducerMap = {};

      function ProducerMapper() {
        this._buildMap();
      }

      ProducerMapper.prototype.findProducerClassForSubscription = function(subscriptionKey) {
        var producerClass;
        producerClass = this.subscriptionKeyToProducerMap[subscriptionKey];
        if (!(this.producers.length > 0)) {
          throw "There are no producers registered - register producers through the DataCommunicationManager";
        }
        if (!producerClass) {
          throw "No producer found for subscription " + subscriptionKey + "!";
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
              return delete _this.subscriptionKeyToProducerMap[subscriptionKey];
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
              return _this.subscriptionKeyToProducerMap[subscriptionKey] = producer;
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
    Poller = function() {
      return {
        get: function() {
          return {};
        }
      };
    };

    /*
    	Base class for services interacting with the API (polling)
    	Each service is bound to a repository and whenever that repository has a listener
    	for data, the service will start polling. If the repository has no active listeners the
    	service will stop polling for data.
     */
    ApiService = (function() {
      var ServiceRepository;

      ServiceRepository = Vigor.ServiceRepository;

      ApiService.prototype.service = void 0;

      ApiService.prototype.repository = void 0;

      ApiService.prototype.poller = void 0;

      ApiService.prototype.pollerOptions = void 0;

      ApiService.prototype.shouldStop = false;

      function ApiService(repository, pollInterval) {
        this.repository = repository;
        if (pollInterval == null) {
          pollInterval = 10000;
        }
        this._stopPolling = __bind(this._stopPolling, this);
        this._startPolling = __bind(this._startPolling, this);
        this.parse = __bind(this.parse, this);
        this.service = new Backbone.Model();
        this.service.url = '';
        this.service.parse = this.parse;
        if (this.repository) {
          this.bindRepositoryListeners();
        }
        this.pollerOptions = {
          delay: pollInterval,
          delayed: false,
          continueOnError: true,
          autostart: false
        };
        this._createPoller(this.pollerOptions);
      }

      ApiService.prototype.dispose = function() {
        if (this.repository) {
          this.unbindRepositoryListeners();
        }
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

      ApiService.prototype.bindRepositoryListeners = function() {
        this.service.listenTo(this.repository, ServiceRepository.prototype.START_POLLING, this._startPolling);
        return this.service.listenTo(this.repository, ServiceRepository.prototype.STOP_POLLING, this._stopPolling);
      };

      ApiService.prototype.unbindRepositoryListeners = function() {
        this.service.stopListening(this.repository, ServiceRepository.prototype.START_POLLING, this._startPolling);
        return this.service.stopListening(this.repository, ServiceRepository.prototype.STOP_POLLING, this._stopPolling);
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

      ApiService.prototype._startPolling = function() {
        var _ref;
        return (_ref = this.poller) != null ? _ref.start() : void 0;
      };

      ApiService.prototype._stopPolling = function() {
        if (this.poller.active()) {
          return this.shouldStop = true;
        } else {
          return this.poller.stop();
        }
      };

      ApiService.prototype._validateResponse = function(response) {
        var removeThisLineOfCode;
        removeThisLineOfCode = response;
        return true;
      };

      return ApiService;

    })();
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
        if (_.indexOf(keys, subscriptionKey) === -1) {
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
        var producer;
        this.subscriptionsWithComponentIdentifiers[subscriptionKey] = [];
        producer = this.producerManager.getProducer(subscriptionKey);
        return this.subscriptionsWithProducers[subscriptionKey] = producer;
      };

      DataCommunicationManager.prototype._removeSubscription = function(subscriptionKey) {
        delete this.subscriptionsWithComponentIdentifiers[subscriptionKey];
        delete this.subscriptionsWithProducers[subscriptionKey];
        return this.producerManager.removeProducer(subscriptionKey);
      };

      DataCommunicationManager.prototype._addComponentToSubscription = function(subscriptionKey, componentIdentifier) {
        var existingComponent, subscriptionComponents;
        subscriptionComponents = this.subscriptionsWithComponentIdentifiers[subscriptionKey];
        existingComponent = _.find(subscriptionComponents, function(component) {
          return component.id === componentIdentifier.id;
        });
        if (!existingComponent) {
          subscriptionComponents.push(componentIdentifier);
          return this.producerManager.addComponentToProducer(subscriptionKey, componentIdentifier);
        }
      };

      DataCommunicationManager.prototype._removeComponentFromSubscription = function(subscriptionKey, componentId) {
        var component, componentIndex, components, index, _i, _len;
        components = this.subscriptionsWithComponentIdentifiers[subscriptionKey];
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
        var componentIdentifiers;
        componentIdentifiers = this.subscriptionsWithComponentIdentifiers[subscriptionKey];
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
          return this.viewModel = options.viewModel;
        }
      };

      ComponentView.prototype.render = function() {
        this.renderStaticContent();
        this.addSubscriptions();
        return this;
      };

      ComponentView.prototype.renderStaticContent = function() {};

      ComponentView.prototype.renderDynamicContent = function() {};

      ComponentView.prototype.addSubscriptions = function() {};

      ComponentView.prototype.removeSubscriptions = function() {};

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

      ViewModel.extend = Backbone.View.extend;

      return ViewModel;

    })();
    Vigor.ViewModel = ViewModel;
    Repository = (function(_super) {
      __extends(Repository, _super);

      function Repository() {
        return Repository.__super__.constructor.apply(this, arguments);
      }

      return Repository;

    })(Backbone.Collection);
    Vigor.Repository = Repository;
    ServiceRepository = (function(_super) {
      __extends(ServiceRepository, _super);

      function ServiceRepository() {
        this._debounced = __bind(this._debounced, this);
        this._onRemove = __bind(this._onRemove, this);
        this._onChange = __bind(this._onChange, this);
        this._onAdd = __bind(this._onAdd, this);
        return ServiceRepository.__super__.constructor.apply(this, arguments);
      }

      ServiceRepository.prototype.producersInterestedInUpdates = void 0;

      ServiceRepository.prototype._debouncedAddedModels = void 0;

      ServiceRepository.prototype._debouncedChangedModels = void 0;

      ServiceRepository.prototype._debouncedRemovedModels = void 0;

      ServiceRepository.prototype._eventTimeout = void 0;

      ServiceRepository.prototype.initialize = function() {
        this._debouncedAddedModels = {};
        this._debouncedChangedModels = {};
        this._debouncedRemovedModels = {};
        this.producersInterestedInUpdates = [];
        this.addDebouncedListeners();
        return ServiceRepository.__super__.initialize.apply(this, arguments);
      };

      ServiceRepository.prototype.addDebouncedListeners = function() {
        return this.on('all', this._onAll);
      };

      ServiceRepository.prototype.isEmpty = function() {
        return this.models.length <= 0;
      };

      ServiceRepository.prototype.interestedInUpdates = function(name) {
        var producerAlreadyInterested;
        producerAlreadyInterested = _.indexOf(this.producersInterestedInUpdates, name) > -1;
        if (producerAlreadyInterested) {
          return;
        } else {
          this.producersInterestedInUpdates.push(name);
        }
        if (this.producersInterestedInUpdates.length > 0) {
          return this.trigger(ServiceRepository.prototype.START_POLLING);
        }
      };

      ServiceRepository.prototype.notInterestedInUpdates = function(name) {
        var interestedProducerIndex;
        interestedProducerIndex = _.indexOf(this.producersInterestedInUpdates, name);
        if (interestedProducerIndex > -1) {
          this.producersInterestedInUpdates.splice(interestedProducerIndex, 1);
        }
        if (this.producersInterestedInUpdates.length === 0) {
          return this.trigger(ServiceRepository.prototype.STOP_POLLING);
        }
      };

      ServiceRepository.prototype._onAll = function() {
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

      ServiceRepository.prototype._onAdd = function(model) {
        return this._debouncedAddedModels[model.id] = model;
      };

      ServiceRepository.prototype._onChange = function(model) {
        return this._debouncedChangedModels[model.id] = model;
      };

      ServiceRepository.prototype._onRemove = function(model) {
        return this._debouncedRemovedModels[model.id] = model;
      };

      ServiceRepository.prototype._debouncedAdd = function() {
        var event, models;
        event = ServiceRepository.prototype.REPOSITORY_ADD;
        models = _.values(this._debouncedAddedModels);
        this._debouncedAddedModels = {};
        if (models.length > 0) {
          this.trigger(event, models, event);
        }
        return models;
      };

      ServiceRepository.prototype._debouncedChange = function() {
        var event, models;
        event = ServiceRepository.prototype.REPOSITORY_CHANGE;
        models = _.values(this._debouncedChangedModels);
        this._debouncedChangedModels = {};
        if (models.length > 0) {
          this.trigger(event, models, event);
        }
        return models;
      };

      ServiceRepository.prototype._debouncedRemove = function() {
        var event, models;
        event = ServiceRepository.prototype.REPOSITORY_REMOVE;
        models = _.values(this._debouncedRemovedModels);
        this._debouncedRemovedModels = {};
        if (models.length > 0) {
          this.trigger(event, models, event);
        }
        return models;
      };

      ServiceRepository.prototype._debouncedDiff = function(added, changed, removed) {
        var event, models;
        event = ServiceRepository.prototype.REPOSITORY_DIFF;
        if (added.length || changed.length || removed.length) {
          models = {
            added: _.difference(added, removed),
            changed: changed,
            removed: removed
          };
          return this.trigger(event, models, event);
        }
      };

      ServiceRepository.prototype._debounced = function() {
        return this._debouncedDiff(this._debouncedAdd(), this._debouncedChange(), this._debouncedRemove());
      };

      ServiceRepository.prototype.POLL_ONCE = 'poll_once';

      ServiceRepository.prototype.START_POLLING = 'start_polling';

      ServiceRepository.prototype.STOP_POLLING = 'stop_polling';

      ServiceRepository.prototype.REPOSITORY_DIFF = 'repository_diff';

      ServiceRepository.prototype.REPOSITORY_ADD = 'repository_add';

      ServiceRepository.prototype.REPOSITORY_CHANGE = 'repository_change';

      ServiceRepository.prototype.REPOSITORY_REMOVE = 'repository_remove';

      return ServiceRepository;

    })(Vigor.Repository);
    Vigor.ServiceRepository = ServiceRepository;
    return Vigor;
  });

}).call(this);
