/*!
 * vigorjs - A small framework for structuring large scale Backbone applications
 * @version 0.1.0
 * @link https://github.com/kambisports/VigorJS.git
 * @license ISC
 */
(function webpackUniversalModuleDefinition(root, factory) {
	if(typeof exports === 'object' && typeof module === 'object')
		module.exports = factory(require("lodash"), require("backbone"));
	else if(typeof define === 'function' && define.amd)
		define(["lodash", "backbone"], factory);
	else if(typeof exports === 'object')
		exports["Vigor"] = factory(require("lodash"), require("backbone"));
	else
		root["Vigor"] = factory(root["_"], root["Backbone"]);
})(this, function(__WEBPACK_EXTERNAL_MODULE_2__, __WEBPACK_EXTERNAL_MODULE_3__) {
return /******/ (function(modules) { // webpackBootstrap
/******/ 	// The module cache
/******/ 	var installedModules = {};
/******/
/******/ 	// The require function
/******/ 	function __webpack_require__(moduleId) {
/******/
/******/ 		// Check if module is in cache
/******/ 		if(installedModules[moduleId])
/******/ 			return installedModules[moduleId].exports;
/******/
/******/ 		// Create a new module (and put it into the cache)
/******/ 		var module = installedModules[moduleId] = {
/******/ 			exports: {},
/******/ 			id: moduleId,
/******/ 			loaded: false
/******/ 		};
/******/
/******/ 		// Execute the module function
/******/ 		modules[moduleId].call(module.exports, module, module.exports, __webpack_require__);
/******/
/******/ 		// Flag the module as loaded
/******/ 		module.loaded = true;
/******/
/******/ 		// Return the exports of the module
/******/ 		return module.exports;
/******/ 	}
/******/
/******/
/******/ 	// expose the modules object (__webpack_modules__)
/******/ 	__webpack_require__.m = modules;
/******/
/******/ 	// expose the module cache
/******/ 	__webpack_require__.c = installedModules;
/******/
/******/ 	// __webpack_public_path__
/******/ 	__webpack_require__.p = "";
/******/
/******/ 	// Load entry module and return exports
/******/ 	return __webpack_require__(0);
/******/ })
/************************************************************************/
/******/ ([
/* 0 */
/***/ function(module, exports, __webpack_require__) {

	'use strict';
	
	Object.defineProperty(exports, "__esModule", {
		value: true
	});
	exports.ServiceRepository = exports.Repository = exports.Producer = exports.IdProducer = exports.APIService = exports.validateContract = exports.setup = exports.settings = exports.Subscription = exports.ProducerMapper = exports.ProducerManager = exports.ComponentViewModel = exports.ComponentView = exports.ComponentBase = exports.SubscriptionKeys = exports.EventKeys = exports.EventBus = undefined;
	
	var _EventBus = __webpack_require__(1);
	
	var _EventBus2 = _interopRequireDefault(_EventBus);
	
	var _EventKeys = __webpack_require__(4);
	
	var _EventKeys2 = _interopRequireDefault(_EventKeys);
	
	var _SubscriptionKeys = __webpack_require__(5);
	
	var _SubscriptionKeys2 = _interopRequireDefault(_SubscriptionKeys);
	
	var _ComponentBase = __webpack_require__(6);
	
	var _ComponentBase2 = _interopRequireDefault(_ComponentBase);
	
	var _ComponentView = __webpack_require__(7);
	
	var _ComponentView2 = _interopRequireDefault(_ComponentView);
	
	var _ComponentViewModel = __webpack_require__(8);
	
	var _ComponentViewModel2 = _interopRequireDefault(_ComponentViewModel);
	
	var _ProducerManager = __webpack_require__(9);
	
	var _ProducerManager2 = _interopRequireDefault(_ProducerManager);
	
	var _ProducerMapper = __webpack_require__(10);
	
	var _ProducerMapper2 = _interopRequireDefault(_ProducerMapper);
	
	var _Subscription = __webpack_require__(11);
	
	var _Subscription2 = _interopRequireDefault(_Subscription);
	
	var _validateContract = __webpack_require__(12);
	
	var _validateContract2 = _interopRequireDefault(_validateContract);
	
	var _settings = __webpack_require__(13);
	
	var _APIService = __webpack_require__(14);
	
	var _APIService2 = _interopRequireDefault(_APIService);
	
	var _IdProducer = __webpack_require__(15);
	
	var _IdProducer2 = _interopRequireDefault(_IdProducer);
	
	var _Producer = __webpack_require__(16);
	
	var _Producer2 = _interopRequireDefault(_Producer);
	
	var _Repository = __webpack_require__(17);
	
	var _Repository2 = _interopRequireDefault(_Repository);
	
	var _ServiceRepository = __webpack_require__(18);
	
	var _ServiceRepository2 = _interopRequireDefault(_ServiceRepository);
	
	function _interopRequireDefault(obj) { return obj && obj.__esModule ? obj : { default: obj }; }
	
	var Vigor = {
		EventBus: _EventBus2.default,
		EventKeys: _EventKeys2.default,
		SubscriptionKeys: _SubscriptionKeys2.default,
		ComponentBase: _ComponentBase2.default,
		ComponentView: _ComponentView2.default,
		ComponentViewModel: _ComponentViewModel2.default,
		ProducerManager: _ProducerManager2.default,
		ProducerMapper: _ProducerMapper2.default,
		Subscription: _Subscription2.default,
		settings: _settings.settings,
		setup: _settings.setup,
		validateContract: _validateContract2.default,
		APIService: _APIService2.default,
		IdProducer: _IdProducer2.default,
		Producer: _Producer2.default,
		Repository: _Repository2.default,
		ServiceRepository: _ServiceRepository2.default
	};
	
	exports.default = Vigor;
	
	// In the long run this should be the only export needed, default
	// default above is
	
	exports.EventBus = _EventBus2.default;
	exports.EventKeys = _EventKeys2.default;
	exports.SubscriptionKeys = _SubscriptionKeys2.default;
	exports.ComponentBase = _ComponentBase2.default;
	exports.ComponentView = _ComponentView2.default;
	exports.ComponentViewModel = _ComponentViewModel2.default;
	exports.ProducerManager = _ProducerManager2.default;
	exports.ProducerMapper = _ProducerMapper2.default;
	exports.Subscription = _Subscription2.default;
	exports.settings = _settings.settings;
	exports.setup = _settings.setup;
	exports.validateContract = _validateContract2.default;
	exports.APIService = _APIService2.default;
	exports.IdProducer = _IdProducer2.default;
	exports.Producer = _Producer2.default;
	exports.Repository = _Repository2.default;
	exports.ServiceRepository = _ServiceRepository2.default;

/***/ },
/* 1 */
/***/ function(module, exports, __webpack_require__) {

	'use strict';
	
	Object.defineProperty(exports, "__esModule", {
		value: true
	});
	
	var _createClass = function () { function defineProperties(target, props) { for (var i = 0; i < props.length; i++) { var descriptor = props[i]; descriptor.enumerable = descriptor.enumerable || false; descriptor.configurable = true; if ("value" in descriptor) descriptor.writable = true; Object.defineProperty(target, descriptor.key, descriptor); } } return function (Constructor, protoProps, staticProps) { if (protoProps) defineProperties(Constructor.prototype, protoProps); if (staticProps) defineProperties(Constructor, staticProps); return Constructor; }; }();
	
	var _underscore = __webpack_require__(2);
	
	var _underscore2 = _interopRequireDefault(_underscore);
	
	var _backbone = __webpack_require__(3);
	
	var _backbone2 = _interopRequireDefault(_backbone);
	
	var _EventKeys = __webpack_require__(4);
	
	var _EventKeys2 = _interopRequireDefault(_EventKeys);
	
	function _interopRequireDefault(obj) { return obj && obj.__esModule ? obj : { default: obj }; }
	
	function _classCallCheck(instance, Constructor) { if (!(instance instanceof Constructor)) { throw new TypeError("Cannot call a class as a function"); } }
	
	var EventRegistry = function EventRegistry() {
		_classCallCheck(this, EventRegistry);
	};
	
	_underscore2.default.extend(EventRegistry.prototype, _backbone2.default);
	
	// A global EventBus for the entire application
	//
	// @example How to subscribe to events
	//   EventBus.subscribe EventKeys.EXAMPLE_EVENT_KEY, (event) ->
	//			# do something with `event` here...
	//
	
	var EventBus = function () {
		function EventBus() {
			_classCallCheck(this, EventBus);
		}
	
		_createClass(EventBus, [{
			key: 'subscribe',
	
	
			// Bind a `callback` function to an event key. Passing `all` as key will
			// bind the callback to all events fired.
			//
			// @param [String] the event key to subscribe to. See datacommunication/EventKeys for available keys.
			// @param [function] the callback that receives the event when it is sent
			value: function subscribe(key, callback) {
				if (!this._eventKeyExists(key)) {
					throw 'key \'' + key + '\' does not exist in EventKeys';
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
	
		}, {
			key: 'subscribeOnce',
			value: function subscribeOnce(key, callback) {
				if (!this._eventKeyExists(key)) {
					throw 'key \'' + key + '\' does not exist in EventKeys';
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
	
		}, {
			key: 'unsubscribe',
			value: function unsubscribe(key, callback) {
				if (!this._eventKeyExists(key)) {
					throw 'key \'' + key + '\' does not exist in EventKeys';
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
	
		}, {
			key: 'send',
			value: function send(key, message) {
				if (!this._eventKeyExists(key)) {
					throw 'key \'' + key + '\' does not exist in EventKeys';
				}
	
				return this.eventRegistry.trigger(key, message);
			}
		}, {
			key: '_eventKeyExists',
			value: function _eventKeyExists(key) {
				var keys = [];
				for (var property in _EventKeys2.default) {
					var value = _EventKeys2.default[property];
					keys.push(value);
				}
				return keys.indexOf(key) >= 0;
			}
		}]);
	
		return EventBus;
	}();
	
	EventBus.prototype.eventRegistry = new EventRegistry();
	
	exports.default = new EventBus();

/***/ },
/* 2 */
/***/ function(module, exports) {

	module.exports = __WEBPACK_EXTERNAL_MODULE_2__;

/***/ },
/* 3 */
/***/ function(module, exports) {

	module.exports = __WEBPACK_EXTERNAL_MODULE_3__;

/***/ },
/* 4 */
/***/ function(module, exports, __webpack_require__) {

	'use strict';
	
	Object.defineProperty(exports, "__esModule", {
	  value: true
	});
	
	var _underscore = __webpack_require__(2);
	
	var _underscore2 = _interopRequireDefault(_underscore);
	
	function _interopRequireDefault(obj) { return obj && obj.__esModule ? obj : { default: obj }; }
	
	var EventKeys = {
	  ALL_EVENTS: 'all',
	  extend: function extend(object) {
	    _underscore2.default.extend(EventKeys, object);
	    return EventKeys;
	  }
	};
	
	exports.default = EventKeys;

/***/ },
/* 5 */
/***/ function(module, exports, __webpack_require__) {

	'use strict';
	
	Object.defineProperty(exports, "__esModule", {
	  value: true
	});
	
	var _underscore = __webpack_require__(2);
	
	var _underscore2 = _interopRequireDefault(_underscore);
	
	function _interopRequireDefault(obj) { return obj && obj.__esModule ? obj : { default: obj }; }
	
	var SubscriptionKeys = {
	  extend: function extend(object) {
	    _underscore2.default.extend(SubscriptionKeys, object);
	    return SubscriptionKeys;
	  }
	};
	
	exports.default = SubscriptionKeys;

/***/ },
/* 6 */
/***/ function(module, exports, __webpack_require__) {

	'use strict';
	
	Object.defineProperty(exports, "__esModule", {
	  value: true
	});
	
	var _createClass = function () { function defineProperties(target, props) { for (var i = 0; i < props.length; i++) { var descriptor = props[i]; descriptor.enumerable = descriptor.enumerable || false; descriptor.configurable = true; if ("value" in descriptor) descriptor.writable = true; Object.defineProperty(target, descriptor.key, descriptor); } } return function (Constructor, protoProps, staticProps) { if (protoProps) defineProperties(Constructor.prototype, protoProps); if (staticProps) defineProperties(Constructor, staticProps); return Constructor; }; }();
	
	var _underscore = __webpack_require__(2);
	
	var _underscore2 = _interopRequireDefault(_underscore);
	
	var _backbone = __webpack_require__(3);
	
	function _interopRequireDefault(obj) { return obj && obj.__esModule ? obj : { default: obj }; }
	
	function _classCallCheck(instance, Constructor) { if (!(instance instanceof Constructor)) { throw new TypeError("Cannot call a class as a function"); } }
	
	// ##ComponentBase
	// This class is intended to be the public interface for a component.
	//
	// By default it exposes a render and a dispose method which should be overridden
	//
	// To create a component you would typically do a index file which extends ComponentBase
	// and then instantiate any views, models, collections etc. that the component need
	// within the index file.
	
	var ComponentBase = function () {
	  function ComponentBase() {
	    _classCallCheck(this, ComponentBase);
	  }
	
	  _createClass(ComponentBase, [{
	    key: 'render',
	
	    // **render:** <br/>
	    // Override this method
	    value: function render() {
	      throw 'ComponentBase->render needs to be over-ridden';
	    }
	
	    // **dispose:** <br/>
	    // Override this method
	
	  }, {
	    key: 'dispose',
	    value: function dispose() {
	      throw 'ComponentBase->dispose needs to be over-ridden';
	    }
	  }], [{
	    key: 'extend',
	
	    // ComponentBase.extend = Backbone.Model.extend;
	    // Add Vigor.extend (Backbone.Model.extend) <br/>
	    // [Backbone.Model.extend](http://backbonejs.org/#Model-extend)
	    get: function get() {
	      return _backbone.Model.extend;
	    }
	  }]);
	
	  return ComponentBase;
	}();
	
	// Extends Backbone.Events <br/>
	// [Backbone.Events](http://backbonejs.org/#Events)
	
	
	_underscore2.default.extend(ComponentBase.prototype, _backbone.Events);
	
	exports.default = ComponentBase;

/***/ },
/* 7 */
/***/ function(module, exports, __webpack_require__) {

	'use strict';
	
	Object.defineProperty(exports, "__esModule", {
	  value: true
	});
	
	var _createClass = function () { function defineProperties(target, props) { for (var i = 0; i < props.length; i++) { var descriptor = props[i]; descriptor.enumerable = descriptor.enumerable || false; descriptor.configurable = true; if ("value" in descriptor) descriptor.writable = true; Object.defineProperty(target, descriptor.key, descriptor); } } return function (Constructor, protoProps, staticProps) { if (protoProps) defineProperties(Constructor.prototype, protoProps); if (staticProps) defineProperties(Constructor, staticProps); return Constructor; }; }();
	
	var _get = function get(object, property, receiver) { if (object === null) object = Function.prototype; var desc = Object.getOwnPropertyDescriptor(object, property); if (desc === undefined) { var parent = Object.getPrototypeOf(object); if (parent === null) { return undefined; } else { return get(parent, property, receiver); } } else if ("value" in desc) { return desc.value; } else { var getter = desc.get; if (getter === undefined) { return undefined; } return getter.call(receiver); } };
	
	var _backbone = __webpack_require__(3);
	
	function _classCallCheck(instance, Constructor) { if (!(instance instanceof Constructor)) { throw new TypeError("Cannot call a class as a function"); } }
	
	function _possibleConstructorReturn(self, call) { if (!self) { throw new ReferenceError("this hasn't been initialised - super() hasn't been called"); } return call && (typeof call === "object" || typeof call === "function") ? call : self; }
	
	function _inherits(subClass, superClass) { if (typeof superClass !== "function" && superClass !== null) { throw new TypeError("Super expression must either be null or a function, not " + typeof superClass); } subClass.prototype = Object.create(superClass && superClass.prototype, { constructor: { value: subClass, enumerable: false, writable: true, configurable: true } }); if (superClass) Object.setPrototypeOf ? Object.setPrototypeOf(subClass, superClass) : subClass.__proto__ = superClass; }
	
	// ##ComponentView
	// This class is intended to be used as a base class for all views within a component
	// It enforces five methods to unify the structure of ComponentViews accross a large application:
	//
	// - renderStaticContent
	// - renderDynamicContent
	// - addSubscriptions
	// - removeSubscriptions
	// - dispose
	//
	
	var ComponentView = function (_View) {
	  _inherits(ComponentView, _View);
	
	  // **constructor** <br/>
	  function ComponentView(options) {
	    _classCallCheck(this, ComponentView);
	
	    // These methods are required to make our view code
	    // structure more consistent (just make them empty if
	    // you don't need them).
	    var _this = _possibleConstructorReturn(this, (ComponentView.__proto__ || Object.getPrototypeOf(ComponentView)).call(this, options));
	
	    _this._checkIfImplemented(['renderStaticContent', 'renderDynamicContent', 'addSubscriptions', 'removeSubscriptions', 'dispose']);
	
	    return _this;
	  }
	
	  // **initialize** <br/>
	  // @param object <br/>
	  // @return this: Object <br/>
	  // view options, usually containing a viewModel instance <br/>
	
	
	  _createClass(ComponentView, [{
	    key: 'initialize',
	    value: function initialize(options) {
	      if (options && options.viewModel) {
	        this.viewModel = options.viewModel;
	      }
	      _get(ComponentView.prototype.__proto__ || Object.getPrototypeOf(ComponentView.prototype), 'initialize', this).apply(this, arguments);
	      return this;
	    }
	
	    // **render** <br/>
	    // @return this: Object <br/>
	    // the views render method, it will call @renderStaticContent and @addSubscriptions <br/>
	
	  }, {
	    key: 'render',
	    value: function render() {
	      this.renderStaticContent();
	      this.addSubscriptions();
	      return this;
	    }
	
	    // **renderStaticContent** <br/>
	    // @return this: Object <br/>
	    // Override this. <br/>
	    // Render parts of component that don't rely on model. <br/>
	
	  }, {
	    key: 'renderStaticContent',
	    value: function renderStaticContent() {
	      return this;
	    }
	
	    // **renderDynamicContent** <br/>
	    // @return this: Object <br/>
	    // Override this. <br/>
	    // Render parts of component that relies on model. <br/>
	
	  }, {
	    key: 'renderDynamicContent',
	    value: function renderDynamicContent() {
	      return this;
	    }
	
	    // **addSubscriptions** <br/>
	    // @return this: Object <br/>
	    // Override this. <br/>
	    // Add view model subscriptions if needed. <br/>
	
	  }, {
	    key: 'addSubscriptions',
	    value: function addSubscriptions() {
	      return this;
	    }
	
	    // **removeSubscriptions** <br/>
	    // @return this: Object <br/>
	    // Override this. <br/>
	    // Remove view model subscriptions.
	
	  }, {
	    key: 'removeSubscriptions',
	    value: function removeSubscriptions() {
	      return this;
	    }
	
	    // **dispose** <br/>
	    // Removes events and dom elements related to the view <br/>
	    // Override this, and call super.
	
	  }, {
	    key: 'dispose',
	    value: function dispose() {
	      if (this.model) {
	        this.model.unbind();
	      }
	      this.removeSubscriptions();
	      this.stopListening();
	      this.$el.off();
	      this.$el.remove();
	      return this.off();
	    }
	
	    // **_checkIfImplemented** <br/>
	    // @param array: Array <br/>
	    // Ensures that passed methods are implemented in the view
	
	  }, {
	    key: '_checkIfImplemented',
	    value: function _checkIfImplemented(methodNames) {
	      var _this2 = this;
	
	      return function () {
	        var result = [];
	        for (var i = 0; i < methodNames.length; i++) {
	          var methodName = methodNames[i];
	          var item = void 0;
	          if (!_this2.constructor.prototype.hasOwnProperty(methodName)) {
	            throw new Error(_this2.constructor.name + ' - ' + methodName + '() must be implemented in View.');
	          }
	          result.push(item);
	        }
	        return result;
	      }();
	    }
	  }]);
	
	  return ComponentView;
	}(_backbone.View);
	
	exports.default = ComponentView;

/***/ },
/* 8 */
/***/ function(module, exports, __webpack_require__) {

	'use strict';
	
	Object.defineProperty(exports, "__esModule", {
	  value: true
	});
	
	var _createClass = function () { function defineProperties(target, props) { for (var i = 0; i < props.length; i++) { var descriptor = props[i]; descriptor.enumerable = descriptor.enumerable || false; descriptor.configurable = true; if ("value" in descriptor) descriptor.writable = true; Object.defineProperty(target, descriptor.key, descriptor); } } return function (Constructor, protoProps, staticProps) { if (protoProps) defineProperties(Constructor.prototype, protoProps); if (staticProps) defineProperties(Constructor, staticProps); return Constructor; }; }();
	
	var _underscore = __webpack_require__(2);
	
	var _underscore2 = _interopRequireDefault(_underscore);
	
	var _backbone = __webpack_require__(3);
	
	var _ProducerManager = __webpack_require__(9);
	
	var _ProducerManager2 = _interopRequireDefault(_ProducerManager);
	
	var _validateContract2 = __webpack_require__(12);
	
	var _validateContract3 = _interopRequireDefault(_validateContract2);
	
	function _interopRequireDefault(obj) { return obj && obj.__esModule ? obj : { default: obj }; }
	
	function _classCallCheck(instance, Constructor) { if (!(instance instanceof Constructor)) { throw new TypeError("Cannot call a class as a function"); } }
	
	// ##ComponentViewModel
	// This class is intended to be the base class for all view models in a component
	//
	// A ComponentViewModel handles communication with producers through the
	// ProducerManager
	var ComponentViewModel = function () {
	  _createClass(ComponentViewModel, null, [{
	    key: 'extend',
	    get: function get() {
	      return _backbone.Model.extend;
	    }
	    // **constructor** <br/>
	    // The constructor generates a unique id for the ViewModel that will be used to
	    // handle subscriptions in the ProducerManager
	
	  }]);
	
	  function ComponentViewModel() {
	    _classCallCheck(this, ComponentViewModel);
	
	    this.id = 'ComponentViewModel_' + _underscore2.default.uniqueId();
	  }
	
	  // **dispose** <br/>
	  // Remves all subscriptions
	
	
	  _createClass(ComponentViewModel, [{
	    key: 'dispose',
	    value: function dispose() {
	      return this.unsubscribeAll();
	    }
	
	    // **subscribe** <br/>
	    // @param [key]: Object <br/>
	    // A Vigor.SubscriptionKey containing a key and contract property<br/>
	    // @param [callback]: Function <br/>
	    // Callback function that takes care of produced data
	    // @param [options]: Object (optional)<br/>
	    // Pass any optional data that might be needed by a Producer
	    //
	    // Adds a subscription on a specific SubscriptionKey to the ProducerManager.
	    // Whenever new data is produced the callback will be called with new data as param
	
	  }, {
	    key: 'subscribe',
	    value: function subscribe(key, callback, options) {
	      return _ProducerManager2.default.subscribe(this.id, key, callback, options);
	    }
	
	    // **unsubscribe** <br/>
	    // @param [key]: Object <br/>
	    // A Vigor.SubscriptionKey containing a key and contract property<br/>
	    //
	    // Removes a subscription on specific key
	
	  }, {
	    key: 'unsubscribe',
	    value: function unsubscribe(key) {
	      return _ProducerManager2.default.unsubscribe(this.id, key);
	    }
	
	    // **unsubscribeAll** <br/>
	    // Removes all subscriptions
	
	  }, {
	    key: 'unsubscribeAll',
	    value: function unsubscribeAll() {
	      return _ProducerManager2.default.unsubscribeAll(this.id);
	    }
	
	    // **validateContract** <br/>
	    // @param [contract]: Object <br/>
	    // The contract specified in the SubscriptionKey used when subscribing for data
	    // @param [incommingData]: Object <br/>
	    // data supplied through the subscription
	    //
	    // Compares contract with incomming data and checks values, types, and number
	    // of properties, call this method manually from your callback if you want to
	    // validate incoming data
	
	  }, {
	    key: 'validateContract',
	    value: function validateContract(contract, incommingData) {
	      return (0, _validateContract3.default)(contract, incommingData, this.id);
	    }
	  }]);
	
	  return ComponentViewModel;
	}();
	
	exports.default = ComponentViewModel;

/***/ },
/* 9 */
/***/ function(module, exports, __webpack_require__) {

	'use strict';
	
	Object.defineProperty(exports, "__esModule", {
	  value: true
	});
	
	var _ProducerMapper = __webpack_require__(10);
	
	var _ProducerMapper2 = _interopRequireDefault(_ProducerMapper);
	
	var _Subscription = __webpack_require__(11);
	
	var _Subscription2 = _interopRequireDefault(_Subscription);
	
	function _interopRequireDefault(obj) { return obj && obj.__esModule ? obj : { default: obj }; }
	
	//  ## ProducerManager
	// The ProducerManager utilizies the [ProducerMapper](ProducerMapper.html) to (un)register components on subscriptions.
	//
	var ProducerManager = {
	
	  // **registerProducers:** </br>
	  // @param [producers]: Array <br/>
	  //
	  // Registers a one or more producers in mapper
	  registerProducers: function registerProducers(producers) {
	    producers.forEach(function (producer) {
	      return _ProducerMapper2.default.register(producer);
	    });
	  },
	
	
	  // **producerForKey:** </br>
	  // @param [subscriptionKey]: String <br/>
	  // @returns [producer]: Producer </br>
	  //
	  // Retrieves a registered producer for the given subscription
	  producerForKey: function producerForKey(subscriptionKey) {
	    return _ProducerMapper2.default.producerForKey(subscriptionKey);
	  },
	
	
	  // **subscribe:** </br>
	  // @param [componentId]: String <br/>
	  // @param [subscriptionKey]: Object <br/>
	  // @param [callback]: Function <br/>
	  // @param [subscriptionOptions]: Object (default empty object) <br/>
	  //
	  // Registers a component with [componentId] to recieve data changes on given [subscriptionKey] through the component [callback]
	  subscribe: function subscribe(componentId, subscriptionKey, callback) {
	    var subscriptionOptions = arguments.length > 3 && arguments[3] !== undefined ? arguments[3] : {};
	
	    var subscription = new _Subscription2.default(componentId, callback, subscriptionOptions);
	    var producer = this.producerForKey(subscriptionKey);
	    producer.addComponent(subscription);
	  },
	
	
	  // **unsubscribe:** </br>
	  // @param [componentId]: String <br/>
	  // @param [subscriptionKey]: String <br/>
	  //
	  // Unsubscribes a component with [componentId] from the producer for the given [subscriptionKey]
	  unsubscribe: function unsubscribe(componentId, subscriptionKey) {
	    var producer = this.producerForKey(subscriptionKey);
	    producer.removeComponent(componentId);
	  },
	
	
	  // **unsubscribeAll:** </br>
	  // @param [componentId]: String <br/>
	  //
	  // Unsubscribes a component with [componentId] from any producer that might have it in its subscription
	  unsubscribeAll: function unsubscribeAll(componentId) {
	    _ProducerMapper2.default.producers.forEach(function (producer) {
	      return producer.prototype.getInstance().removeComponent(componentId);
	    });
	  }
	};
	
	exports.default = ProducerManager;

/***/ },
/* 10 */
/***/ function(module, exports) {

	"use strict";
	
	Object.defineProperty(exports, "__esModule", {
	  value: true
	});
	// Array of currently registered producers
	var producers = [];
	
	// Table look-up of subscription key to mapped producer
	var producersByKey = {};
	
	// Error thrown when no producers at all have been registered and component starts a subscription
	var NO_PRODUCERS_ERROR = "There are no producers registered - register producers through the ProducerManager";
	
	// Error thrown when a component tries to register a subscription and no producer has been registered for that subscription
	var NO_PRODUCER_FOUND_ERROR = function NO_PRODUCER_FOUND_ERROR(key) {
	  return "No producer found for subscription " + key + "!";
	};
	
	// Error thrown when a component tries to register a subscription to a producer has already been registered for that subscription
	var KEY_ALREADY_REGISTERED = function KEY_ALREADY_REGISTERED(key) {
	  return "A producer for the key " + key + " is already registered";
	};
	
	// ##ProducerMapper
	// Mapper class to keep track of the available producers and their corresponding subscriptions
	var ProducerMapper = {
	
	  producers: producers,
	  // **producerClassForKey:** </br>
	  // @param [subscriptionKey]: String <br/>
	  // @returns [producerClass]: Class </br>
	  // @throws [NO_PRODUCERS_ERROR], [NO_PRODUCER_FOUND_ERROR] </br>
	  //
	  // Returns the corresponding producer class for the given [subscriptionKey]
	  producerClassForKey: function producerClassForKey(subscriptionKey) {
	    var key = subscriptionKey.key;
	
	    if (producers.length === 0) {
	      throw NO_PRODUCERS_ERROR;
	    }
	
	    var producerClass = producersByKey[key];
	
	    if (!producerClass) {
	      throw NO_PRODUCER_FOUND_ERROR(key);
	    }
	
	    return producerClass;
	  },
	
	
	  // **producerForKey:** </br>
	  // @param [subscriptionKey]: String <br/>
	  // @returns [producerClass]: Producer </br>
	  //
	  // Returns the instance of the producer mapper to the [subscriptionKey]
	  producerForKey: function producerForKey(subscriptionKey) {
	    var producerClass = this.producerClassForKey(subscriptionKey);
	    return producerClass.prototype.getInstance();
	  },
	
	
	  // **register:** </br>
	  // @param [producerClass]: Class <br/>
	  // @throws [KEY_ALREADY_REGISTERED] </br>
	  //
	  // Registers a new producer type [producerClass] in the mapper
	  register: function register(producerClass) {
	    if (producers.indexOf(producerClass) === -1) {
	      producers.push(producerClass);
	      var subscriptionKey = producerClass.prototype.PRODUCTION_KEY;
	      var key = subscriptionKey.key;
	
	
	      if (producersByKey[key]) {
	        throw KEY_ALREADY_REGISTERED(key);
	      }
	
	      return producersByKey[key] = producerClass;
	    }
	  },
	
	
	  // **reset:** </br>
	  //
	  // Used in unit tests to reset the mapper
	  reset: function reset() {
	    producers.length = 0;
	    return producersByKey = {};
	  }
	};
	
	exports.default = ProducerMapper;

/***/ },
/* 11 */
/***/ function(module, exports) {

	"use strict";
	
	Object.defineProperty(exports, "__esModule", {
	  value: true
	});
	
	function _classCallCheck(instance, Constructor) { if (!(instance instanceof Constructor)) { throw new TypeError("Cannot call a class as a function"); } }
	
	var Subscription = function Subscription(id, callback, options) {
	  _classCallCheck(this, Subscription);
	
	  this.id = id;
	  this.callback = callback;
	  this.options = options;
	};
	
	exports.default = Subscription;

/***/ },
/* 12 */
/***/ function(module, exports, __webpack_require__) {

	'use strict';
	
	Object.defineProperty(exports, "__esModule", {
	  value: true
	});
	
	var _typeof = typeof Symbol === "function" && typeof Symbol.iterator === "symbol" ? function (obj) { return typeof obj; } : function (obj) { return obj && typeof Symbol === "function" && obj.constructor === Symbol && obj !== Symbol.prototype ? "symbol" : typeof obj; };
	
	var _underscore = __webpack_require__(2);
	
	var _underscore2 = _interopRequireDefault(_underscore);
	
	var _settings = __webpack_require__(13);
	
	function _interopRequireDefault(obj) { return obj && obj.__esModule ? obj : { default: obj }; }
	
	// **ValidateContract**<br/>
	// @param [contract]: Object<br/>
	// The contract to validate the data against. The contract should match the shape of the expected data object and
	// contain primitive values of the same type as the expected values.
	//
	// @param [dataToCompare]: Object<br/>
	// The data to validate.
	//
	// @param [comparatorId]: String<br/>
	// A human-readable name for the comparator, to be used to make nice error messages when things go wrong.
	//
	// @param [verb]: String<br/>
	// A human-readable name for the action that the comparator is trying to achieve, to be used to make nice error
	// messages when things go wrong. The default value is `receiving`.
	//
	// @returns `true` if the data is valid according to the given contract, `false` otherwise.
	//
	// Validates the given data according to the given contract. If the shape or any of the primitive types of the data
	// object differ from the contract object, the contract is violated and this function returns `false`. Otherwise, it
	// returns `true`.
	var validateContract = function validateContract(contract, dataToCompare, comparatorId) {
	  var verb = arguments.length > 3 && arguments[3] !== undefined ? arguments[3] : 'recieving';
	
	  if (!_settings.settings.shouldValidateContract) {
	    return;
	  }
	  if (!contract) {
	    throw new Error('The ' + comparatorId + ' does not have any contract specified');
	    return false;
	  }
	
	  if (!dataToCompare) {
	    throw new Error(comparatorId + ' is trying to validate the contract but does not recieve any data to compare against the contract');
	    return false;
	  }
	
	  if (_underscore2.default.isArray(contract) && _underscore2.default.isArray(dataToCompare) === false) {
	    throw new Error(comparatorId + '\'s compared data is supposed to be an array but is a ' + (typeof dataToCompare === 'undefined' ? 'undefined' : _typeof(dataToCompare)));
	    return false;
	  }
	
	  if (_underscore2.default.isObject(contract) && _underscore2.default.isArray(contract) === false && _underscore2.default.isArray(dataToCompare)) {
	    throw new Error(comparatorId + '\'s compared data is supposed to be an object but is an array');
	    return false;
	  }
	
	  if (_underscore2.default.isObject(contract) && _underscore2.default.isArray(contract) === false) {
	    var contractKeyCount = _underscore2.default.keys(contract).length;
	    var dataKeyCount = _underscore2.default.keys(dataToCompare).length;
	
	    if (dataKeyCount > contractKeyCount) {
	      throw new Error(comparatorId + ' is ' + verb + ' more data then what is specified in the contract', contract, dataToCompare);
	      return false;
	    } else if (dataKeyCount < contractKeyCount) {
	      throw new Error(comparatorId + ' is ' + verb + ' less data then what is specified in the contract', contract, dataToCompare);
	      return false;
	    }
	  }
	
	  for (var key in contract) {
	
	    var val = contract[key];
	    if (!(key in dataToCompare)) {
	      throw new Error(comparatorId + ' has data but is missing the key: ' + key);
	      return false;
	    }
	
	    if (val != null) {
	      if (_typeof(dataToCompare[key]) !== (typeof val === 'undefined' ? 'undefined' : _typeof(val))) {
	        throw new Error(comparatorId + ' is ' + verb + ' data of the wrong type according to the contract, ' + key + ', expects ' + (typeof val === 'undefined' ? 'undefined' : _typeof(val)) + ' but gets ' + _typeof(dataToCompare[key]));
	        return false;
	      }
	    }
	  }
	
	  return true;
	};
	
	exports.default = validateContract;

/***/ },
/* 13 */
/***/ function(module, exports, __webpack_require__) {

	'use strict';
	
	Object.defineProperty(exports, "__esModule", {
		value: true
	});
	exports.setup = exports.settings = undefined;
	
	var _underscore = __webpack_require__(2);
	
	var _underscore2 = _interopRequireDefault(_underscore);
	
	function _interopRequireDefault(obj) { return obj && obj.__esModule ? obj : { default: obj }; }
	
	var settings = {
		shouldValidateContract: false
	};
	
	function setup(newSettings) {
		_underscore2.default.extend(settings, newSettings);
	}
	
	exports.settings = settings;
	exports.setup = setup;

/***/ },
/* 14 */
/***/ function(module, exports, __webpack_require__) {

	'use strict';
	
	Object.defineProperty(exports, "__esModule", {
	  value: true
	});
	
	var _createClass = function () { function defineProperties(target, props) { for (var i = 0; i < props.length; i++) { var descriptor = props[i]; descriptor.enumerable = descriptor.enumerable || false; descriptor.configurable = true; if ("value" in descriptor) descriptor.writable = true; Object.defineProperty(target, descriptor.key, descriptor); } } return function (Constructor, protoProps, staticProps) { if (protoProps) defineProperties(Constructor.prototype, protoProps); if (staticProps) defineProperties(Constructor, staticProps); return Constructor; }; }();
	
	var _underscore = __webpack_require__(2);
	
	var _underscore2 = _interopRequireDefault(_underscore);
	
	var _backbone = __webpack_require__(3);
	
	function _interopRequireDefault(obj) { return obj && obj.__esModule ? obj : { default: obj }; }
	
	function _classCallCheck(instance, Constructor) { if (!(instance instanceof Constructor)) { throw new TypeError("Cannot call a class as a function"); } }
	
	// ## ServiceChannel
	// The ServiceChannel class is private to the APIService class. Service channels are used to group subscriptions to an
	// API service into sets of subscriptions whose requirements can be fulfilled with a single request, thus reducing
	// network usage.<br/>
	// Each subscription to the channel may have a polling interval, and the channel will ask the service that created
	// it to perform a fetch when the polling intervals elapse.<br/>
	// Service channels are not used for post requests, which are always started immediately, idependent of other requests,
	// and cannot be polled.
	var ServiceChannel = function () {
	
	  // If subscribers are provided, the requests will start immediately.
	  function ServiceChannel(_window, name, service, subscribers) {
	    _classCallCheck(this, ServiceChannel);
	
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
	
	
	  _createClass(ServiceChannel, [{
	    key: 'restart',
	    value: function restart() {
	      var wait = void 0;
	      this.pollingInterval = this.getPollingInterval();
	      if (this.lastPollTime != null) {
	        var elapsedWait = this._window.Date.now() - this.lastPollTime;
	        wait = Math.max(this.pollingInterval - elapsedWait, 0);
	      } else {
	        wait = 0;
	      }
	      this.setupNextFetch(wait);
	    }
	
	    // **stop**<br/>
	    // Stops the channel and asks the service to remove it.
	
	  }, {
	    key: 'stop',
	    value: function stop() {
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
	
	  }, {
	    key: 'setupNextFetch',
	    value: function setupNextFetch() {
	      var _this = this;
	
	      var wait = arguments.length > 0 && arguments[0] !== undefined ? arguments[0] : this.pollingInterval;
	
	      this._window.clearTimeout(this.timeout);
	
	      this.timeout = this._window.setTimeout(function () {
	        _this.lastPollTime = _this._window.Date.now();
	        _this.service.fetch(_this.params);
	        // Remove requests with a zero polling interval since the request has now been made
	        _this.cullImmediateRequests();
	
	        // Check to make sure we still have subscribers after culling
	        // immediate requests
	        if (_this.subscribers) {
	          // if we still have subscribers, set up the next fetch
	          if (_this.pollingInterval > 0) {
	            _this.setupNextFetch();
	          } else {
	            _this.timeout = undefined;
	          }
	        }
	      }, wait);
	    }
	
	    // **addSubscription**<br/>
	    // @param [subscriber]: Object<br/>
	    // The subscription to add. May contain a pollingInterval in ms, and a params object.
	    //
	    // Add a subscription to the channel, causing the params to update. A fetch may be scheduled or rescheduled.
	
	  }, {
	    key: 'addSubscription',
	    value: function addSubscription(subscriber) {
	      if (!_underscore2.default.includes(this.subscribers, subscriber)) {
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
	
	  }, {
	    key: 'removeSubscription',
	    value: function removeSubscription(subscriber) {
	      if (_underscore2.default.includes(this.subscribers, subscriber)) {
	        this.subscribers = _underscore2.default.without(this.subscribers, subscriber);
	
	        if (this.subscribers.length === 0) {
	          this.stop();
	        } else {
	          this.onSubscriptionsChanged();
	        }
	      }
	    }
	
	    // **onSubscriptionsChanged**<br/>
	    // Updates the params and reschedules the next fetch if necessary.
	
	  }, {
	    key: 'onSubscriptionsChanged',
	    value: function onSubscriptionsChanged() {
	      var params = this.getParams();
	      var didParamsChange = !_underscore2.default.isEqual(params, this.params);
	
	      var oldParams = this.params;
	      this.params = params;
	
	      var shouldFetchImmediately = false;
	
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
	
	  }, {
	    key: 'getPollingInterval',
	    value: function getPollingInterval() {
	      var pollingIntervals = _underscore2.default.map(this.subscribers, function (subscriber) {
	        return subscriber.pollingInterval;
	      });
	      var pollingInterval = _underscore2.default.min(pollingIntervals);
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
	
	  }, {
	    key: 'getParams',
	    value: function getParams() {
	      var params = _underscore2.default.map(this.subscribers, function (subscriber) {
	        return subscriber.params;
	      });
	      params = _underscore2.default.compact(params);
	      return this.service.consolidateParams(params, this.name);
	    }
	
	    // **cullImmediateRequests**<br/>
	    // Removes all subscribers that do not have a polling interval.
	
	  }, {
	    key: 'cullImmediateRequests',
	    value: function cullImmediateRequests() {
	      var _this2 = this;
	
	      var immediateRequests = _underscore2.default.filter(this.subscribers, function (subscriber) {
	        return subscriber.pollingInterval === undefined || subscriber.pollingInterval === 0;
	      });
	
	      // Remove the immediate requests. This will never trigger a
	      // restart because the polling interval is zero and cannot be lowered
	      _underscore2.default.each(immediateRequests, function (immediateRequest) {
	        return _this2.removeSubscription(immediateRequest);
	      });
	
	      this.pollingInterval = this.getPollingInterval();
	    }
	  }]);
	
	  return ServiceChannel;
	}();
	
	// ## APIService
	// An API service makes XHRs when it is subscribed to.
	
	
	var APIService = function () {
	  _createClass(APIService, null, [{
	    key: 'extend',
	    get: function get() {
	      return _backbone.Model.extend;
	    }
	
	    // Optionally pass in a window object to stub Date, set/clearTimeout for testing
	
	  }]);
	
	  function APIService() {
	    var _window = arguments.length > 0 && arguments[0] !== undefined ? arguments[0] : window;
	
	    _classCallCheck(this, APIService);
	
	    var service = this;
	    // An object referencing the channels owned by this service by name
	    this.channels = {};
	    this._window = _window;
	
	    this.Model = _backbone.Model.extend({
	      sync: function sync(method, model, options) {
	        return service.sync(method, model, options);
	      },
	      url: function url() {
	        return service.url(this);
	      },
	      parse: function parse(resp, options) {
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
	
	
	  _createClass(APIService, [{
	    key: 'consolidateParams',
	    value: function consolidateParams(paramsArray, channelName) {
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
	
	  }, {
	    key: 'channelForParams',
	    value: function channelForParams(params) {
	      // `null`/`undefined` should be equivalent to an empty params object
	      return JSON.stringify(params) || "{}";
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
	
	  }, {
	    key: 'shouldFetchOnParamsUpdate',
	    value: function shouldFetchOnParamsUpdate(newParams, oldParams, channelName) {
	      return true;
	    }
	
	    // **onFetchSuccess**<br/>
	    // Called when a fetch is successful.
	
	  }, {
	    key: 'onFetchSuccess',
	    value: function onFetchSuccess() {}
	
	    // **onFetchError**<br/>
	    // Called when a fetch is unsuccessful.
	
	  }, {
	    key: 'onFetchError',
	    value: function onFetchError() {}
	
	    // **onPostSuccess**<br/>
	    // Called when a post request is successful.
	
	  }, {
	    key: 'onPostSuccess',
	    value: function onPostSuccess() {}
	
	    // **onPostError**<br/>
	    // Called when a post request is unsuccessful.
	
	  }, {
	    key: 'onPostError',
	    value: function onPostError() {}
	
	    // **sync**<br/>
	    // See [Backbone.Model.sync](http://backbonejs.org/#Model-sync)
	
	  }, {
	    key: 'sync',
	    value: function sync(method, model, options) {
	      return _backbone.Model.prototype.sync.call(model, method, model, options);
	    }
	
	    // **url**<br/>
	    // See [Backbone.Model.url](http://backbonejs.org/#Model-url)
	
	  }, {
	    key: 'url',
	    value: function url(model) {
	      _backbone.Model.prototype.url.call(model);
	    }
	
	    // **parse**<br/>
	    // See [Backbone.Model.parse](http://backbonejs.org/#Model-parse)
	
	  }, {
	    key: 'parse',
	    value: function parse(resp, options, model) {
	      _backbone.Model.prototype.parse.call(model);
	    }
	
	    // **removeChannel**<br/>
	    // @param [channel]: String<br/>
	    // The name of the channel to remove
	    //
	    // Removes the given channel. Called by channels when they are no longer required.
	
	  }, {
	    key: 'removeChannel',
	    value: function removeChannel(channel) {
	      delete this.channels[channel.name];
	    }
	
	    // **addSubscription**<br/>
	    // @param [subscriber]: Object
	    // A subscription to the service. This must contain an HTTP method: `GET` and `POST` are currently supported.<br/>
	    // For fetches, this should also contain a `params` object and optionally a `pollingInterval` in ms.<br/>
	    // For posts, this should contain a `postParams` object.
	    //
	    // Adds a subscription to the service, triggering a request.
	
	  }, {
	    key: 'addSubscription',
	    value: function addSubscription(subscriber) {
	      var method = subscriber.method || 'GET';
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
	
	  }, {
	    key: 'addGetSubscription',
	    value: function addGetSubscription(subscriber) {
	      var channelName = this.channelForParams(subscriber.params);
	      var channel = this.channels[channelName];
	
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
	
	  }, {
	    key: 'removeSubscription',
	    value: function removeSubscription(subscriber) {
	      if (subscriber) {
	        var channelId = this.channelForParams(subscriber.params);
	        var channel = this.channels[channelId];
	
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
	
	  }, {
	    key: 'getModelInstance',
	    value: function getModelInstance(params) {
	      return new this.Model(params);
	    }
	
	    // **propagateResponse**<br/>
	    // See [Backbone.Events.trigger](http://backbonejs.org/#Events-trigger)
	
	  }, {
	    key: 'propagateResponse',
	    value: function propagateResponse(key, responseData) {
	      return this.trigger(key, responseData);
	    }
	
	    // **fetch**<br/>
	    // @param [params]: Object<br/>
	    // The consolidated params for a request
	    //
	    // Makes a fetch request with the given params. Either onFetchSuccess or onFetchError
	    // will be called when the request is resolved.
	
	  }, {
	    key: 'fetch',
	    value: function fetch(params) {
	      var model = this.getModelInstance(params);
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
	
	  }, {
	    key: 'post',
	    value: function post(params) {
	      var model = this.getModelInstance(params);
	      return model.save(undefined, {
	        success: this.onPostSuccess,
	        error: this.onPostError
	      });
	    }
	  }]);
	
	  return APIService;
	}();
	
	_underscore2.default.extend(APIService.prototype, _backbone.Events);
	
	exports.default = APIService;

/***/ },
/* 15 */
/***/ function(module, exports, __webpack_require__) {

	'use strict';
	
	Object.defineProperty(exports, "__esModule", {
	  value: true
	});
	
	var _typeof = typeof Symbol === "function" && typeof Symbol.iterator === "symbol" ? function (obj) { return typeof obj; } : function (obj) { return obj && typeof Symbol === "function" && obj.constructor === Symbol && obj !== Symbol.prototype ? "symbol" : typeof obj; };
	
	var _createClass = function () { function defineProperties(target, props) { for (var i = 0; i < props.length; i++) { var descriptor = props[i]; descriptor.enumerable = descriptor.enumerable || false; descriptor.configurable = true; if ("value" in descriptor) descriptor.writable = true; Object.defineProperty(target, descriptor.key, descriptor); } } return function (Constructor, protoProps, staticProps) { if (protoProps) defineProperties(Constructor.prototype, protoProps); if (staticProps) defineProperties(Constructor, staticProps); return Constructor; }; }();
	
	var _underscore = __webpack_require__(2);
	
	var _underscore2 = _interopRequireDefault(_underscore);
	
	var _Producer2 = __webpack_require__(16);
	
	var _Producer3 = _interopRequireDefault(_Producer2);
	
	function _interopRequireDefault(obj) { return obj && obj.__esModule ? obj : { default: obj }; }
	
	function _classCallCheck(instance, Constructor) { if (!(instance instanceof Constructor)) { throw new TypeError("Cannot call a class as a function"); } }
	
	function _possibleConstructorReturn(self, call) { if (!self) { throw new ReferenceError("this hasn't been initialised - super() hasn't been called"); } return call && (typeof call === "object" || typeof call === "function") ? call : self; }
	
	function _inherits(subClass, superClass) { if (typeof superClass !== "function" && superClass !== null) { throw new TypeError("Super expression must either be null or a function, not " + typeof superClass); } subClass.prototype = Object.create(superClass && superClass.prototype, { constructor: { value: subClass, enumerable: false, writable: true, configurable: true } }); if (superClass) Object.setPrototypeOf ? Object.setPrototypeOf(subClass, superClass) : subClass.__proto__ = superClass; }
	
	// ## IdProducer
	//
	// An IdProducer produces data for multiple models.
	//
	// When an ordinary producer produces data, it produces all of its data to all of its subscribers.<br/>
	// An IdProducer produces data for multiple data models, each of which has its own id.
	// A subscription to an IdProducer specifies an id which corresponds to the model it is interested in.
	// When a model's data changes, the IdProducer produces the data for that model to the subscribers that
	// are subscribed to that model's id.
	
	
	var IdProducer = function (_Producer) {
	  _inherits(IdProducer, _Producer);
	
	  _createClass(IdProducer, [{
	    key: 'idType',
	
	
	    // This is the type of the model ids.<br/>
	    // This should be value types, and are numbers by default.<br/>
	    // Trying to add a subscription with an invalid type throws an error.
	    get: function get() {
	      return this._idType || _typeof(0);
	    },
	    set: function set(type) {
	      this._idType = type;
	    }
	  }]);
	
	  function IdProducer() {
	    _classCallCheck(this, IdProducer);
	
	    // An array containing the ids of the models that have been added, removed
	    // or updated since the last time data was produced
	    var _this = _possibleConstructorReturn(this, (IdProducer.__proto__ || Object.getPrototypeOf(IdProducer)).apply(this, arguments));
	
	    _this.updatedIds = [];
	
	    // A map of the subscriptions to this producer. The keys of this map are model ids
	    // and the values are arrays of subscription options objects.
	    _this.subscriptions = {};
	    return _this;
	  }
	
	  // **subscribe**<br/>
	  // @param [options]: Object<br/>
	  // Subsciption options. Can be used to get the id to unsubscribe from.
	  //
	  // Subscribe to the producer, if the id is of valid type.
	
	
	  _createClass(IdProducer, [{
	    key: 'subscribe',
	    value: function subscribe(options) {
	      var id = this.idForOptions(options);
	      if ((typeof id === 'undefined' ? 'undefined' : _typeof(id)) !== this.idType) {
	        throw 'expected the subscription key to be a ' + this.idType + ' but got a ' + (typeof subscriptionKey === 'undefined' ? 'undefined' : _typeof(subscriptionKey));
	      }
	      if (this.subscriptions[id]) {
	        this.subscriptions[id].push(options);
	      } else {
	        this.subscriptions[id] = [options];
	      }
	
	      return this.produceDataSync(id);
	    }
	
	    // **onDiffInRepository**<br/>
	    // @param [repository]: [Repository](Repository.html)<br/>
	    // The repository whose data changed.
	    //
	    // @param [diff]: Object<br/>
	    // An object containing arrays of data items that were added, removed and changed
	    //
	    // Handles updates from repositories. Filters the given models to only those that have subscriptions
	    // and produces data for them.
	
	  }, {
	    key: 'onDiffInRepository',
	    value: function onDiffInRepository(repository, diff) {
	      var _this2 = this;
	
	      var addRemoveMap = function addRemoveMap(model) {
	        var id = _this2.idForModel(model, repository);
	        if (_underscore2.default.isArray(id)) {
	          return _underscore2.default.filter(id, _this2.hasId.bind(_this2));
	        } else if (_this2.hasId(id)) {
	          return id;
	        }
	      };
	
	      var changeMap = function changeMap(model) {
	        if (_this2.shouldPropagateModelChange(model, repository)) {
	          var id = _this2.idForModel(model, repository);
	          if (_underscore2.default.isArray(id)) {
	            return _underscore2.default.filter(id, _this2.hasId.bind(_this2));
	          } else if (_this2.hasId(id)) {
	            return id;
	          }
	        }
	      };
	
	      var addedModelIds = _underscore2.default.map(diff.added, addRemoveMap);
	      var removedModelIds = _underscore2.default.map(diff.removed, addRemoveMap);
	      var updatedModelIds = _underscore2.default.map(diff.changed, changeMap);
	
	      var ids = _underscore2.default.flattenDepth([addedModelIds, removedModelIds, updatedModelIds], 2);
	      ids = _underscore2.default.compact(ids);
	
	      this.produceDataForIds(ids);
	    }
	
	    // **produceDataForIds**<br/>
	    // @param [ids]: Array of idTypes<br/>
	    // An array of model ids to produce data for. Defaults to all subscribed models.<br/>
	    //
	    // Produces data for all given model ids.
	
	  }, {
	    key: 'produceDataForIds',
	    value: function produceDataForIds() {
	      var ids = arguments.length > 0 && arguments[0] !== undefined ? arguments[0] : this.allIds();
	
	      this.updatedIds = _underscore2.default.uniq(this.updatedIds.concat(ids));
	      return this.produceData();
	    }
	
	    // **allIds**<br/>
	    // @returns [ids]: Array of idTypes<br/>
	    // All subscribed ids.
	    //
	    // Returns an array of all subscribed ids.
	
	  }, {
	    key: 'allIds',
	    value: function allIds() {
	      var ids = _underscore2.default.keys(this.subscriptions);
	
	      if (this.idType === _typeof(0)) {
	        ids = _underscore2.default.map(ids, function (id) {
	          return parseInt(id, 10);
	        });
	      }
	
	      return ids;
	    }
	
	    // **produceData**<br/>
	    // Aynchronously produces data for all models whose data has changed since the last time data was produced.
	
	    // **produceDataSync**<br/>
	    // @param [id]: idType<br/>
	    // The id to produce data for. Defaults to all ids whose data has changed since the last time data was produced.
	    //
	    // Synchronously produces data for all models whose data has changed since the last time data was produced. If an id is supplied, only data for the model with that id is produced.
	
	  }, {
	    key: 'produceDataSync',
	    value: function produceDataSync(id) {
	      if (id) {
	        return this.produce([id]);
	      } else if (this.updatedIds.length > 0) {
	        var ids = this.updatedIds.slice();
	        this.updatedIds.length = 0;
	
	        return this.produce(ids);
	      }
	    }
	
	    // **unsubscribe** <br/>
	    // @param [options]: Object <br/>
	    // Subsciption options. Can be used to get the id to unsubscribe from. This must be the same reference as the options used when subscribing (i.e. ===).
	    //
	    // Unsubscribe from the producer.
	
	  }, {
	    key: 'unsubscribe',
	    value: function unsubscribe(options) {
	      var id = this.idForOptions(options);
	      var subscription = this.subscriptions[id];
	      if (subscription) {
	        var index = subscription.indexOf(options);
	        if (index !== -1) {
	          subscription.splice(index, 1);
	
	          if (subscription.length === 0) {
	            delete this.subscriptions[id];
	          }
	        }
	      }
	    }
	
	    // **produce**<br/>
	    // @param [ids]: Array of idTypes<br/>
	    // List of ids to produce data for.
	    //
	    // Produce (gathered, decorated and validated) data for the ids.
	
	  }, {
	    key: 'produce',
	    value: function produce(ids) {
	      var _this3 = this;
	
	      var data = void 0;
	      ids.forEach(function (id) {
	        data = _this3.currentData(id) || {};
	        data.id = id;
	        data = _this3.decorate(data);
	        _this3._validateContract(data);
	
	        _underscore2.default.each(_this3.registeredComponents, function (component) {
	          if (id === _this3.idForOptions(component.options)) {
	            return component.callback(data);
	          }
	        });
	      });
	    }
	
	    // **currentData**<br/>
	    // @param [id]: The id to produce data for
	    //
	    // This is where the actual collection of the data is done. <br/>
	
	  }, {
	    key: 'currentData',
	    value: function currentData(id) {}
	    // default implementation is a noop
	
	    // **hasId**<br/>
	    // @param [id]: idType<br/>
	    // The id to check for.
	    //
	    // @returns [hasId]: boolean<br/>
	    // True if there is a subscription for the given id, false otherwise.
	    //
	    // Returns true if there is a subscription for the given id, otherwise returns false.
	
	  }, {
	    key: 'hasId',
	    value: function hasId(id) {
	      return this.subscriptions[id] != null;
	    }
	
	    // **shouldPropagateModelChange**<br/>
	    // @param [model]: Object<br/>
	    // A model
	    //
	    // @param [repository]: [Repository](Repository.html)<br/>
	    // The repository which contains the model.<br/>
	    //
	    // Called when a model changes to determine whether to produce data for the model. If true, then data for the model will be produced for this change.
	
	  }, {
	    key: 'shouldPropagateModelChange',
	    value: function shouldPropagateModelChange(model, repository) {
	      return true;
	    }
	
	    // **idForModel**<br/>
	    // @param [model]: Object<br/>
	    // A model
	    //
	    // @param [repository]: [Repository](Repository.html)<br/>
	    // The repository which contains the model.
	    //
	    // @returns [id]: idType or array of idTypes<br/>
	    // The internal id of the given model, or an array of internal ids which correspond to the given model.
	    //
	    // Translates a model to an id or array of ids of type idType which uniquely identifies the model internally to this producer.
	
	  }, {
	    key: 'idForModel',
	    value: function idForModel(model, repository) {
	      return model.id;
	    }
	
	    // **idForOptions**<br/>
	    // @param [options]: Object<br/>
	    // A subscription options object.
	    //
	    // @returns [id]: idType<br/>
	    // The internal id of the model that the subscription options refer to.
	    //
	    // Translates subscription options to an id of type idType which uniquely identifies the model internally to this producer.
	
	  }, {
	    key: 'idForOptions',
	    value: function idForOptions(options) {
	      return options.id;
	    }
	  }]);
	
	  return IdProducer;
	}(_Producer3.default);
	
	exports.default = IdProducer;

/***/ },
/* 16 */
/***/ function(module, exports, __webpack_require__) {

	'use strict';
	
	Object.defineProperty(exports, "__esModule", {
	  value: true
	});
	
	var _createClass = function () { function defineProperties(target, props) { for (var i = 0; i < props.length; i++) { var descriptor = props[i]; descriptor.enumerable = descriptor.enumerable || false; descriptor.configurable = true; if ("value" in descriptor) descriptor.writable = true; Object.defineProperty(target, descriptor.key, descriptor); } } return function (Constructor, protoProps, staticProps) { if (protoProps) defineProperties(Constructor.prototype, protoProps); if (staticProps) defineProperties(Constructor, staticProps); return Constructor; }; }();
	
	var _underscore = __webpack_require__(2);
	
	var _underscore2 = _interopRequireDefault(_underscore);
	
	var _backbone = __webpack_require__(3);
	
	var _Repository = __webpack_require__(17);
	
	var _Repository2 = _interopRequireDefault(_Repository);
	
	var _validateContract2 = __webpack_require__(12);
	
	var _validateContract3 = _interopRequireDefault(_validateContract2);
	
	function _interopRequireDefault(obj) { return obj && obj.__esModule ? obj : { default: obj }; }
	
	function _classCallCheck(instance, Constructor) { if (!(instance instanceof Constructor)) { throw new TypeError("Cannot call a class as a function"); } }
	
	// ## Producer
	//
	// A Producer listens to data changes in one or several repositories
	// and produces data on a certain Production Key.
	//
	//
	
	var Producer = function () {
	  _createClass(Producer, [{
	    key: 'PRODUCTION_KEY',
	
	
	    // The production key that is used for subscribing to the producer. <br/>
	    // This key should be overridden in the subclass.
	    get: function get() {
	      return this._productionKey;
	    },
	    set: function set(productionKey) {
	      this._productionKey = productionKey;
	    }
	
	    // The repository (or repositories) that the producer listens to.
	
	  }, {
	    key: 'repositories',
	    get: function get() {
	      return this._repositories || [];
	    },
	    set: function set(repositories) {
	      this._repositories = repositories;
	    }
	
	    // The decorator(s) that is used for formatting the produced data.
	
	  }, {
	    key: 'decorators',
	    get: function get() {
	      return this._decorators || [];
	    },
	    set: function set(decorators) {
	      this._decorators = decorators;
	    }
	  }], [{
	    key: 'extend',
	    get: function get() {
	      return _backbone.Model.extend;
	    }
	  }]);
	
	  function Producer() {
	    _classCallCheck(this, Producer);
	
	    this.onDiffInRepository = this.onDiffInRepository.bind(this);
	    this.registeredComponents = {};
	    this.produceData = _underscore2.default.throttle(this.produceDataSync, 100);
	
	    // Keeps track of if the producer has subscribed to its repositories or not.
	    this._isSubscribedToRepositories = false;
	  }
	
	  _createClass(Producer, [{
	    key: 'getInstance',
	    value: function getInstance() {
	      if (this.instance == null) {
	        this.instance = new this.constructor();
	      }
	      return this.instance;
	    }
	
	    // **addComponent** <br/>
	    // @param [subscription]: Object <br/>
	    // The subscription, which contains an id, a callback and options. <br/>
	    //
	    // Adds (subscribes) a component to the producer.
	
	  }, {
	    key: 'addComponent',
	    value: function addComponent(subscription) {
	      var existingSubscription = this.registeredComponents[subscription.id];
	      if (existingSubscription == null) {
	        this.registeredComponents[subscription.id] = subscription;
	        this.subscribe(subscription.options);
	
	        if (!this._isSubscribedToRepositories) {
	          this.subscribeToRepositories();
	          this._isSubscribedToRepositories = true;
	        }
	      }
	    }
	
	    // **removeComponent** <br/>
	    // @param [componentId]: String <br/>
	    // The id of the component that should be removed. <br/>
	    //
	    // Removes a component (its subscription) from the producer.
	
	  }, {
	    key: 'removeComponent',
	    value: function removeComponent(componentId) {
	      var subscription = this.registeredComponents[componentId];
	
	      if (subscription) {
	        this.unsubscribe(subscription.options);
	        delete this.registeredComponents[subscription.id];
	
	        var shouldUnsubscribe = true;
	        for (var component in this.registeredComponents) {
	          shouldUnsubscribe = false;
	          break;
	        }
	
	        if (shouldUnsubscribe) {
	          this.unsubscribeFromRepositories();
	          this._isSubscribedToRepositories = false;
	        }
	      }
	    }
	
	    // **subscribeToRepositories** <br/>
	    // Subscribes to all the repositories. <br/>
	    // Also registers the callback function if the repository has one.
	
	  }, {
	    key: 'subscribeToRepositories',
	    value: function subscribeToRepositories() {
	      var _this = this;
	
	      this.repositories.forEach(function (repository) {
	        if (repository instanceof _Repository2.default) {
	          _this.subscribeToRepository(repository);
	        } else if (repository.repository instanceof _Repository2.default && typeof repository.callback === 'string') {
	          _this.subscribeToRepository(repository.repository, _this[repository.callback]);
	        } else {
	          throw 'unexpected format of producer repositories definition';
	        }
	      });
	    }
	
	    // **unsubscribeFromRepositories** <br/>
	    // Unsubscribes from all the repositories.
	
	  }, {
	    key: 'unsubscribeFromRepositories',
	    value: function unsubscribeFromRepositories() {
	      var _this2 = this;
	
	      this.repositories.forEach(function (repository) {
	        if (repository instanceof _Repository2.default) {
	          _this2.unsubscribeFromRepository(repository);
	        } else if (repository.repository instanceof _Repository2.default && typeof repository.callback === 'string') {
	          _this2.unsubscribeFromRepository(repository.repository);
	        }
	      });
	    }
	
	    // **subscribeToRepository** <br/>
	    // @param [repository]: Object <br/>
	    // The repository to subscribe to. <br/>
	    // @param [callback]: String <br/>
	    // The method that should be executed on repository diff.
	    //
	    // Sets up a subscription to a repository with a custom or predefined callback.
	
	  }, {
	    key: 'subscribeToRepository',
	    value: function subscribeToRepository(repository, callback) {
	      var _this3 = this;
	
	      if (!callback) {
	        callback = function callback(diff) {
	          return _this3.onDiffInRepository(repository, diff);
	        };
	      }
	
	      this.listenTo(repository, _Repository2.default.prototype.REPOSITORY_DIFF, callback);
	    }
	
	    // **unsubscribeFromRepository** <br/>
	    // @param [repository]: Object <br/>
	    // The repository to unsubscribe from.
	    //
	    // Unsubscribes from a repository.
	
	  }, {
	    key: 'unsubscribeFromRepository',
	    value: function unsubscribeFromRepository(repository) {
	      this.stopListening(repository, _Repository2.default.prototype.REPOSITORY_DIFF);
	    }
	
	    // **subscribe** <br/>
	    // Called when a component is added.
	
	  }, {
	    key: 'subscribe',
	    value: function subscribe() {
	      this.produceDataSync();
	    }
	
	    // **onDiffInRepository** <br/>
	    // Used as default callback when subscribing to a repository.
	
	  }, {
	    key: 'onDiffInRepository',
	    value: function onDiffInRepository() {
	      this.produceData();
	    }
	  }, {
	    key: 'produceDataSync',
	    value: function produceDataSync() {
	      this.produce(this.currentData());
	    }
	
	    // ***produce*** <br/>
	    // @param [data]: Object <br/>
	    // The current data.
	    //
	    // This method is called by the produceDataSync method <br/>
	    // and in turn calls methods for decoration of the current data <br/>
	    // and validation of its contract.
	
	  }, {
	    key: 'produce',
	    value: function produce(data) {
	      data = this.decorate(data);
	      this._validateContract(data);
	      for (var componentId in this.registeredComponents) {
	        var component = this.registeredComponents[componentId];
	        component.callback(data);
	      }
	    }
	
	    // **currentData** <br/>
	    // This is where the actual collection of the data is done. <br/>
	    // Default implementation is a noop.
	
	  }, {
	    key: 'currentData',
	    value: function currentData() {}
	
	    // **unsubscribe** <br/>
	    // Default implementation is a noop.
	
	  }, {
	    key: 'unsubscribe',
	    value: function unsubscribe(options) {}
	
	    // **decorate** <br/>
	    // @param [data]: Object <br/>
	    // The data to decorate .<br/>
	    // @return data: Object <br/>
	    // The decorated data.
	    //
	    // Runs the assigned decorator(s) on the data.
	
	  }, {
	    key: 'decorate',
	    value: function decorate(data) {
	      for (var i = 0; i < this.decorators.length; i++) {
	        var decorator = this.decorators[i];
	        decorator(data);
	      }
	      return data;
	    }
	  }, {
	    key: 'modelToJSON',
	    value: function modelToJSON(model) {
	      return model.toJSON();
	    }
	  }, {
	    key: 'modelsToJSON',
	    value: function modelsToJSON(models) {
	      return _underscore2.default.map(models, this.modelToJSON);
	    }
	
	    // **_validateContract** <br/>
	    // @param [dataToProduce]: Object <br/>
	    // The data to validate. <br/>
	    // @return : Boolean
	    //
	    // Used to validate data against a predefined contract, if there is one.
	
	  }, {
	    key: '_validateContract',
	    value: function _validateContract(dataToProduce) {
	      var contract = this.PRODUCTION_KEY.contract;
	
	      if (!contract) {
	        throw new Error('The subscriptionKey ' + subscriptionKey.key + ' doesn\'t have a contract specified');
	      }
	
	      (0, _validateContract3.default)(contract, dataToProduce, this, 'producing');
	    }
	  }, {
	    key: 'extend',
	    value: function extend(obj, mixin) {
	      for (var name in mixin) {
	        var method = mixin[name];
	        obj[name] = method;
	      }
	      return obj;
	    }
	  }, {
	    key: 'mixin',
	    value: function mixin(instance, _mixin) {
	      return this.extend(instance, _mixin);
	    }
	  }]);
	
	  return Producer;
	}();
	
	_underscore2.default.extend(Producer.prototype, _backbone.Events);
	
	exports.default = Producer;

/***/ },
/* 17 */
/***/ function(module, exports, __webpack_require__) {

	'use strict';
	
	Object.defineProperty(exports, "__esModule", {
	  value: true
	});
	
	var _get = function get(object, property, receiver) { if (object === null) object = Function.prototype; var desc = Object.getOwnPropertyDescriptor(object, property); if (desc === undefined) { var parent = Object.getPrototypeOf(object); if (parent === null) { return undefined; } else { return get(parent, property, receiver); } } else if ("value" in desc) { return desc.value; } else { var getter = desc.get; if (getter === undefined) { return undefined; } return getter.call(receiver); } };
	
	var _createClass = function () { function defineProperties(target, props) { for (var i = 0; i < props.length; i++) { var descriptor = props[i]; descriptor.enumerable = descriptor.enumerable || false; descriptor.configurable = true; if ("value" in descriptor) descriptor.writable = true; Object.defineProperty(target, descriptor.key, descriptor); } } return function (Constructor, protoProps, staticProps) { if (protoProps) defineProperties(Constructor.prototype, protoProps); if (staticProps) defineProperties(Constructor, staticProps); return Constructor; }; }();
	
	var _underscore = __webpack_require__(2);
	
	var _underscore2 = _interopRequireDefault(_underscore);
	
	var _backbone = __webpack_require__(3);
	
	function _interopRequireDefault(obj) { return obj && obj.__esModule ? obj : { default: obj }; }
	
	function _classCallCheck(instance, Constructor) { if (!(instance instanceof Constructor)) { throw new TypeError("Cannot call a class as a function"); } }
	
	function _possibleConstructorReturn(self, call) { if (!self) { throw new ReferenceError("this hasn't been initialised - super() hasn't been called"); } return call && (typeof call === "object" || typeof call === "function") ? call : self; }
	
	function _inherits(subClass, superClass) { if (typeof superClass !== "function" && superClass !== null) { throw new TypeError("Super expression must either be null or a function, not " + typeof superClass); } subClass.prototype = Object.create(superClass && superClass.prototype, { constructor: { value: subClass, enumerable: false, writable: true, configurable: true } }); if (superClass) Object.setPrototypeOf ? Object.setPrototypeOf(subClass, superClass) : subClass.__proto__ = superClass; }
	
	//  ## Repository
	//
	// The Repository extends a [Backbone Collection](http://backbonejs.org/#Collection)
	// and adds functionality for diffing and throttling data
	//
	//
	
	var Repository = function (_Collection) {
	  _inherits(Repository, _Collection);
	
	  _createClass(Repository, [{
	    key: 'REPOSITORY_DIFF',
	    get: function get() {
	      return 'repository_diff';
	    }
	  }, {
	    key: 'REPOSITORY_ADD',
	    get: function get() {
	      return 'repository_add';
	    }
	  }, {
	    key: 'REPOSITORY_CHANGE',
	    get: function get() {
	      return 'repository_change';
	    }
	  }, {
	    key: 'REPOSITORY_REMOVE',
	    get: function get() {
	      return 'repository_remove';
	    }
	    // Plain object holding reference to all the Backbone Collection models **added** since last throttled batch
	
	  }]);
	
	  function Repository() {
	    var _ref;
	
	    _classCallCheck(this, Repository);
	
	    for (var _len = arguments.length, args = Array(_len), _key = 0; _key < _len; _key++) {
	      args[_key] = arguments[_key];
	    }
	
	    var _this = _possibleConstructorReturn(this, (_ref = Repository.__proto__ || Object.getPrototypeOf(Repository)).call.apply(_ref, [this].concat(args)));
	
	    _this._onAdd = _this._onAdd.bind(_this);
	    _this._onChange = _this._onChange.bind(_this);
	    _this._onRemove = _this._onRemove.bind(_this);
	    _this._triggerUpdates = _this._triggerUpdates.bind(_this);
	    return _this;
	  }
	
	  _createClass(Repository, [{
	    key: 'initialize',
	    value: function initialize() {
	      _get(Repository.prototype.__proto__ || Object.getPrototypeOf(Repository.prototype), 'initialize', this).apply(this, arguments);
	      this.cid = this.cid || _underscore2.default.uniqueId('c');
	
	      this._throttledAddedModels = {};
	      // Plain object holding reference to all the Backbone Collection models **updated** since last throttled batch
	      this._throttledChangedModels = {};
	      // Plain object holding reference to all the Backbone Collection models **removed** since last throttled batch
	      this._throttledRemovedModels = {};
	
	      // Reference to a [throttled](http://underscorejs.org/#throttle) version of the _triggerUpdates
	      // function in order to avoid flooding the listeners
	      this._throttledTriggerUpdates = _underscore2.default.throttle(this._triggerUpdates, 100, { leading: false });
	
	      this.addThrottledListeners();
	    }
	
	    // **addThrottledListeners** <br/>
	    // Catch all events triggered from Backbone Collection in order to make throttling possible.
	    // It still bubbles the event for outside subscribers.
	
	  }, {
	    key: 'addThrottledListeners',
	    value: function addThrottledListeners() {
	      this.on('all', this._onAll);
	    }
	
	    // **getByIds** <br/>
	    // @param [ids]: Array <br/>
	    // @return models: Array
	
	  }, {
	    key: 'getByIds',
	    value: function getByIds(ids) {
	      var models = [];
	      for (var i = 0; i < ids.length; i++) {
	        var id = ids[i];
	        models.push(this.get(id));
	      }
	      return models;
	    }
	  }, {
	    key: 'isEmpty',
	    value: function isEmpty() {
	      return this.models.length <= 0;
	    }
	
	    // **_onAll** <br/>
	    // see *addThrottledListeners*
	
	  }, {
	    key: '_onAll',
	    value: function _onAll(event, model) {
	      switch (event) {
	        case 'add':
	          this._onAdd(model);break;
	        case 'change':
	          this._onChange(model);break;
	        case 'remove':
	          this._onRemove(model);break;
	      }
	
	      this._throttledTriggerUpdates();
	    }
	  }, {
	    key: '_onAdd',
	    value: function _onAdd(model) {
	      this._throttledAddedModels[model.id] = model;
	    }
	  }, {
	    key: '_onChange',
	    value: function _onChange(model) {
	      this._throttledChangedModels[model.id] = model;
	    }
	  }, {
	    key: '_onRemove',
	    value: function _onRemove(model) {
	      this._throttledRemovedModels[model.id] = model;
	    }
	  }, {
	    key: '_throttledAdd',
	    value: function _throttledAdd() {
	      var event = Repository.prototype.REPOSITORY_ADD;
	      var models = _underscore2.default.values(this._throttledAddedModels);
	      this._throttledAddedModels = {};
	      return this._throttledEvent(event, models, event);
	    }
	  }, {
	    key: '_throttledChange',
	    value: function _throttledChange() {
	      var event = Repository.prototype.REPOSITORY_CHANGE;
	      var models = _underscore2.default.values(this._throttledChangedModels);
	      this._throttledChangedModels = {};
	      return this._throttledEvent(event, models, event);
	    }
	  }, {
	    key: '_throttledRemove',
	    value: function _throttledRemove() {
	      var event = Repository.prototype.REPOSITORY_REMOVE;
	      var models = _underscore2.default.values(this._throttledRemovedModels);
	      this._throttledRemovedModels = {};
	      return this._throttledEvent(event, models, event);
	    }
	  }, {
	    key: '_throttledEvent',
	    value: function _throttledEvent(event, models, eventRef) {
	      if (models.length > 0) {
	        this.trigger(event, models, eventRef);
	      }
	      return models;
	    }
	
	    // **_throttledDiff** <br/>
	    // @param [added]: Array <br/>
	    // @param [changed]: Array <br/>
	    // @param [removed]: Array <br/>
	    //
	    // An event type called REPOSITORY_DIFF is added to the repository which supplies a consolidated
	    // response with all the added, removed and updated models since last throttled batch
	
	  }, {
	    key: '_throttledDiff',
	    value: function _throttledDiff(added, changed, removed) {
	      var event = Repository.prototype.REPOSITORY_DIFF;
	      if (added.length || changed.length || removed.length) {
	
	        added = _underscore2.default.difference(added, removed);
	        var consolidated = _underscore2.default.uniq(added.concat(changed));
	
	        var models = {
	          added: added,
	          changed: changed,
	          removed: removed,
	          consolidated: consolidated
	        };
	
	        this.trigger(event, models, event);
	      }
	    }
	  }, {
	    key: '_triggerUpdates',
	    value: function _triggerUpdates() {
	      this._throttledDiff(this._throttledAdd(), this._throttledChange(), this._throttledRemove());
	    }
	  }]);
	
	  return Repository;
	}(_backbone.Collection);
	
	exports.default = Repository;

/***/ },
/* 18 */
/***/ function(module, exports, __webpack_require__) {

	'use strict';
	
	Object.defineProperty(exports, "__esModule", {
	  value: true
	});
	
	var _createClass = function () { function defineProperties(target, props) { for (var i = 0; i < props.length; i++) { var descriptor = props[i]; descriptor.enumerable = descriptor.enumerable || false; descriptor.configurable = true; if ("value" in descriptor) descriptor.writable = true; Object.defineProperty(target, descriptor.key, descriptor); } } return function (Constructor, protoProps, staticProps) { if (protoProps) defineProperties(Constructor.prototype, protoProps); if (staticProps) defineProperties(Constructor, staticProps); return Constructor; }; }();
	
	var _Repository2 = __webpack_require__(17);
	
	var _Repository3 = _interopRequireDefault(_Repository2);
	
	function _interopRequireDefault(obj) { return obj && obj.__esModule ? obj : { default: obj }; }
	
	function _classCallCheck(instance, Constructor) { if (!(instance instanceof Constructor)) { throw new TypeError("Cannot call a class as a function"); } }
	
	function _possibleConstructorReturn(self, call) { if (!self) { throw new ReferenceError("this hasn't been initialised - super() hasn't been called"); } return call && (typeof call === "object" || typeof call === "function") ? call : self; }
	
	function _inherits(subClass, superClass) { if (typeof superClass !== "function" && superClass !== null) { throw new TypeError("Super expression must either be null or a function, not " + typeof superClass); } subClass.prototype = Object.create(superClass && superClass.prototype, { constructor: { value: subClass, enumerable: false, writable: true, configurable: true } }); if (superClass) Object.setPrototypeOf ? Object.setPrototypeOf(subClass, superClass) : subClass.__proto__ = superClass; }
	
	//  ## ServiceRepository
	//
	// A ServiceRepository extends the Repository class and enables
	// subscriptions for services
	//
	
	var ServiceRepository = function (_Repository) {
	  _inherits(ServiceRepository, _Repository);
	
	  function ServiceRepository() {
	    _classCallCheck(this, ServiceRepository);
	
	    return _possibleConstructorReturn(this, (ServiceRepository.__proto__ || Object.getPrototypeOf(ServiceRepository)).apply(this, arguments));
	  }
	
	  _createClass(ServiceRepository, [{
	    key: 'addSubscriptionToService',
	
	
	    // **addSubscriptionToService** <br/>
	    // @param [service]: Object <br/>
	    // The service to add the subscription to </br>
	    // @param [subscription]: Object <br/>
	    // The subscription to add to the service
	    //
	    // Adds a subscription to a service
	    value: function addSubscriptionToService(service, subscription) {
	      service.addSubscription(subscription);
	    }
	
	    // **removeSubscriptionFromService** <br/>
	    // @param [service]: Object <br/>
	    // The service to remove the subscription from </br>
	    // @param [subscription]: Object <br/>
	    // The subscription to remove from the service
	    //
	    // Removes a subscription from a service
	
	  }, {
	    key: 'removeSubscriptionFromService',
	    value: function removeSubscriptionFromService(service, subscription) {
	      service.removeSubscription(subscription);
	    }
	
	    // **addSubscription** <br/>
	    // @param [type]: String <br/>
	    // Used to identify the service for this subscription.
	    // @param [subscription]: Object <br/>
	    // Used to configure the service request
	    //
	    // Maps the service through type before subscribing
	
	  }, {
	    key: 'addSubscription',
	    value: function addSubscription(type, subscription) {
	      if (this.services[type]) {
	        this.addSubscriptionToService(this.services[type], subscription);
	      }
	    }
	
	    // **removeSubscription** <br/>
	    // @param [type]: String <br/>
	    // Used to identify the service for this subscription.
	    // @param [subscription]: Object <br/>
	    // Used to configure the service request
	    //
	    // Maps the service through type before unsubscribing
	
	  }, {
	    key: 'removeSubscription',
	    value: function removeSubscription(type, subscription) {
	      if (this.services[type]) {
	        this.removeSubscriptionFromService(this.services[type], subscription);
	      }
	    }
	  }, {
	    key: 'services',
	    get: function get() {
	      return this._services || {};
	    },
	    set: function set(services) {
	      this._services = services;
	    }
	  }]);
	
	  return ServiceRepository;
	}(_Repository3.default);
	
	// Expose ServiceRepository on the Vigor object
	
	
	exports.default = ServiceRepository;

/***/ }
/******/ ])
});
;
//# sourceMappingURL=vigor.js.map