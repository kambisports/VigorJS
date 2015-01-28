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
    var ComponentIdentifier, ComponentView, EventBus, EventRegistry, PackageBase, Producer, ProducerManager, ProducerMapper, Repository, ServiceRepository, ViewModel, Vigor, previousVigor;
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
      var EventKeys;

      function EventBus() {}

      EventKeys = Vigor.EventKeys;

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
          var _results;
          _results = [];
          for (property in EventKeys) {
            value = EventKeys[property];
            _results.push(value);
          }
          return _results;
        })(), key) >= 0;
      };

      return EventBus;

    })();
    Vigor.EventBus = new EventBus();
    ComponentView = (function(_super) {
      __extends(ComponentView, _super);

      ComponentView.prototype.viewModel = void 0;

      function ComponentView() {
        this._checkIfImplemented(['renderStaticContent', 'addSubscriptions', 'removeSubscriptions', 'dispose']);
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
    Vigor.PackageBase = PackageBase;
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

      return ViewModel;

    })();
    Vigor.ViewModel = ViewModel;
    Producer = (function() {
      Producer.prototype.subscriptionKeyToComponents = {};

      function Producer() {
        var key, _i, _len, _ref;
        _ref = this.SUBSCRIPTION_KEYS;
        for (_i = 0, _len = _ref.length; _i < _len; _i++) {
          key = _ref[_i];
          this.subscriptionKeyToComponents[key] = [];
        }
      }

      Producer.prototype.dispose = function() {};

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

      Producer.prototype.SUBSCRIPTION_KEYS = [];

      Producer.prototype.NAME = 'Producer';

      return Producer;

    })();
    Vigor.Producer = Producer;
    ProducerMapper = (function() {
      ProducerMapper.prototype.producers = [];

      ProducerMapper.prototype.subscriptionKeyToProducerMap = {};

      function ProducerMapper() {
        this.producers.forEach((function(_this) {
          return function(producer) {
            return producer.prototype.SUBSCRIPTION_KEYS.forEach(function(subscriptionKey) {
              return _this.subscriptionKeyToProducerMap[subscriptionKey] = producer;
            });
          };
        })(this));
      }

      ProducerMapper.prototype.findProducerClassForSubscription = function(subscriptionKey) {
        var producerClass;
        producerClass = this.subscriptionKeyToProducerMap[subscriptionKey];
        if (!producerClass) {
          throw "No producer found for subscription " + subscriptionKey + "!";
        }
        return producerClass;
      };

      return ProducerMapper;

    })();
    Vigor.ProducerMapper = ProducerMapper;
    ProducerManager = (function() {
      function ProducerManager() {}

      ProducerManager.prototype.producerMapper = new Vigor.ProducerMapper();

      ProducerManager.prototype.instansiatedProducers = {};

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
    Vigor.SubscriptionKeys = {};
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
