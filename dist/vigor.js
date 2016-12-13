/*!
 * vigorjs - A small framework for structuring large scale Backbone applications
 * @version 0.1.1
 * @link https://github.com/kambisports/VigorJS.git
 * @license ISC
 */
!function(e,t){"object"==typeof exports&&"object"==typeof module?module.exports=t(require("lodash"),require("backbone")):"function"==typeof define&&define.amd?define(["lodash","backbone"],t):"object"==typeof exports?exports.Vigor=t(require("lodash"),require("backbone")):e.Vigor=t(e._,e.Backbone)}(this,function(e,t){return function(e){function t(r){if(n[r])return n[r].exports;var o=n[r]={exports:{},id:r,loaded:!1};return e[r].call(o.exports,o,o.exports,t),o.loaded=!0,o.exports}var n={};return t.m=e,t.c=n,t.p="",t(0)}([function(e,t,n){"use strict";function r(e){return e&&e.__esModule?e:{default:e}}Object.defineProperty(t,"__esModule",{value:!0}),t.ServiceRepository=t.Repository=t.Producer=t.IdProducer=t.APIService=t.validateContract=t.setup=t.settings=t.Subscription=t.ProducerMapper=t.ProducerManager=t.ComponentViewModel=t.ComponentView=t.ComponentBase=t.SubscriptionKeys=t.EventKeys=t.EventBus=void 0;var o=n(1),i=r(o),u=n(4),s=r(u),a=n(5),c=r(a),l=n(6),f=r(l),d=n(7),p=r(d),h=n(8),y=r(h),v=n(9),b=r(v),_=n(10),g=r(_),m=n(11),k=r(m),w=n(12),O=r(w),P=n(13),S=n(14),E=r(S),M=n(15),C=r(M),I=n(16),T=r(I),R=n(17),j=r(R),x=n(18),F=r(x),D={EventBus:i.default,EventKeys:s.default,SubscriptionKeys:c.default,ComponentBase:f.default,ComponentView:p.default,ComponentViewModel:y.default,ProducerManager:b.default,ProducerMapper:g.default,Subscription:k.default,settings:P.settings,setup:P.setup,validateContract:O.default,APIService:E.default,IdProducer:C.default,Producer:T.default,Repository:j.default,ServiceRepository:F.default};t.default=D,t.EventBus=i.default,t.EventKeys=s.default,t.SubscriptionKeys=c.default,t.ComponentBase=f.default,t.ComponentView=p.default,t.ComponentViewModel=y.default,t.ProducerManager=b.default,t.ProducerMapper=g.default,t.Subscription=k.default,t.settings=P.settings,t.setup=P.setup,t.validateContract=O.default,t.APIService=E.default,t.IdProducer=C.default,t.Producer=T.default,t.Repository=j.default,t.ServiceRepository=F.default},function(e,t,n){"use strict";function r(e){return e&&e.__esModule?e:{default:e}}function o(e,t){if(!(e instanceof t))throw new TypeError("Cannot call a class as a function")}Object.defineProperty(t,"__esModule",{value:!0});var i=function(){function e(e,t){for(var n=0;n<t.length;n++){var r=t[n];r.enumerable=r.enumerable||!1,r.configurable=!0,"value"in r&&(r.writable=!0),Object.defineProperty(e,r.key,r)}}return function(t,n,r){return n&&e(t.prototype,n),r&&e(t,r),t}}(),u=n(2),s=r(u),a=n(3),c=r(a),l=n(4),f=r(l),d=function e(){o(this,e)};s.default.extend(d.prototype,c.default);var p=function(){function e(){o(this,e)}return i(e,[{key:"subscribe",value:function(e,t){if(!this._eventKeyExists(e))throw"key '"+e+"' does not exist in EventKeys";if("function"!=typeof t)throw"callback is not a function";return this.eventRegistry.on(e,t)}},{key:"subscribeOnce",value:function(e,t){if(!this._eventKeyExists(e))throw"key '"+e+"' does not exist in EventKeys";if("function"!=typeof t)throw"callback is not a function";return this.eventRegistry.once(e,t)}},{key:"unsubscribe",value:function(e,t){if(!this._eventKeyExists(e))throw"key '"+e+"' does not exist in EventKeys";if("function"!=typeof t)throw"callback is not a function";return this.eventRegistry.off(e,t)}},{key:"send",value:function(e,t){if(!this._eventKeyExists(e))throw"key '"+e+"' does not exist in EventKeys";return this.eventRegistry.trigger(e,t)}},{key:"_eventKeyExists",value:function(e){var t=[];for(var n in f.default)if(f.default.hasOwnProperty(n)){var r=f.default[n];t.push(r)}return t.indexOf(e)>=0}}]),e}();p.prototype.eventRegistry=new d,t.default=new p},function(t,n){t.exports=e},function(e,n){e.exports=t},function(e,t,n){"use strict";function r(e){return e&&e.__esModule?e:{default:e}}Object.defineProperty(t,"__esModule",{value:!0});var o=n(2),i=r(o),u={ALL_EVENTS:"all",extend:function(e){return i.default.extend(u,e),u}};t.default=u},function(e,t,n){"use strict";function r(e){return e&&e.__esModule?e:{default:e}}Object.defineProperty(t,"__esModule",{value:!0});var o=n(2),i=r(o),u={extend:function(e){return i.default.extend(u,e),u}};t.default=u},function(e,t,n){"use strict";function r(e){return e&&e.__esModule?e:{default:e}}function o(e,t){if(!(e instanceof t))throw new TypeError("Cannot call a class as a function")}Object.defineProperty(t,"__esModule",{value:!0});var i=function(){function e(e,t){for(var n=0;n<t.length;n++){var r=t[n];r.enumerable=r.enumerable||!1,r.configurable=!0,"value"in r&&(r.writable=!0),Object.defineProperty(e,r.key,r)}}return function(t,n,r){return n&&e(t.prototype,n),r&&e(t,r),t}}(),u=n(2),s=r(u),a=n(3),c=function(){function e(){o(this,e)}return i(e,[{key:"render",value:function(){throw"ComponentBase->render needs to be over-ridden"}},{key:"dispose",value:function(){throw"ComponentBase->dispose needs to be over-ridden"}}],[{key:"extend",get:function(){return a.Model.extend}}]),e}();s.default.extend(c.prototype,a.Events),t.default=c},function(e,t,n){"use strict";function r(e,t){if(!(e instanceof t))throw new TypeError("Cannot call a class as a function")}function o(e,t){if(!e)throw new ReferenceError("this hasn't been initialised - super() hasn't been called");return!t||"object"!=typeof t&&"function"!=typeof t?e:t}function i(e,t){if("function"!=typeof t&&null!==t)throw new TypeError("Super expression must either be null or a function, not "+typeof t);e.prototype=Object.create(t&&t.prototype,{constructor:{value:e,enumerable:!1,writable:!0,configurable:!0}}),t&&(Object.setPrototypeOf?Object.setPrototypeOf(e,t):e.__proto__=t)}Object.defineProperty(t,"__esModule",{value:!0});var u=function(){function e(e,t){for(var n=0;n<t.length;n++){var r=t[n];r.enumerable=r.enumerable||!1,r.configurable=!0,"value"in r&&(r.writable=!0),Object.defineProperty(e,r.key,r)}}return function(t,n,r){return n&&e(t.prototype,n),r&&e(t,r),t}}(),s=function e(t,n,r){null===t&&(t=Function.prototype);var o=Object.getOwnPropertyDescriptor(t,n);if(void 0===o){var i=Object.getPrototypeOf(t);return null===i?void 0:e(i,n,r)}if("value"in o)return o.value;var u=o.get;if(void 0!==u)return u.call(r)},a=n(3),c=function(e){function t(e){r(this,t);var n=o(this,(t.__proto__||Object.getPrototypeOf(t)).call(this,e));return n._checkIfImplemented(["renderStaticContent","renderDynamicContent","addSubscriptions","removeSubscriptions","dispose"]),n}return i(t,e),u(t,[{key:"initialize",value:function(e){return e&&e.viewModel&&(this.viewModel=e.viewModel),s(t.prototype.__proto__||Object.getPrototypeOf(t.prototype),"initialize",this).apply(this,arguments),this}},{key:"render",value:function(){return this.renderStaticContent(),this.addSubscriptions(),this}},{key:"renderStaticContent",value:function(){return this}},{key:"renderDynamicContent",value:function(){return this}},{key:"addSubscriptions",value:function(){return this}},{key:"removeSubscriptions",value:function(){return this}},{key:"dispose",value:function(){return this.model&&this.model.unbind(),this.removeSubscriptions(),this.stopListening(),this.$el.off(),this.$el.remove(),this.off()}},{key:"_checkIfImplemented",value:function(e){var t=this;return function(){for(var n=[],r=0;r<e.length;r++){var o=e[r],i=void 0;if(!t.constructor.prototype.hasOwnProperty(o))throw new Error(t.constructor.name+" - "+o+"() must be implemented in View.");n.push(i)}return n}()}}]),t}(a.View);t.default=c},function(e,t,n){"use strict";function r(e){return e&&e.__esModule?e:{default:e}}function o(e,t){if(!(e instanceof t))throw new TypeError("Cannot call a class as a function")}Object.defineProperty(t,"__esModule",{value:!0});var i=function(){function e(e,t){for(var n=0;n<t.length;n++){var r=t[n];r.enumerable=r.enumerable||!1,r.configurable=!0,"value"in r&&(r.writable=!0),Object.defineProperty(e,r.key,r)}}return function(t,n,r){return n&&e(t.prototype,n),r&&e(t,r),t}}(),u=n(2),s=r(u),a=n(3),c=n(9),l=r(c),f=n(12),d=r(f),p=function(){function e(){o(this,e),this.id="ComponentViewModel_"+s.default.uniqueId()}return i(e,null,[{key:"extend",get:function(){return a.Model.extend}}]),i(e,[{key:"dispose",value:function(){return this.unsubscribeAll()}},{key:"subscribe",value:function(e,t,n){return l.default.subscribe(this.id,e,t,n)}},{key:"unsubscribe",value:function(e){return l.default.unsubscribe(this.id,e)}},{key:"unsubscribeAll",value:function(){return l.default.unsubscribeAll(this.id)}},{key:"validateContract",value:function(e,t){return(0,d.default)(e,t,this.id)}}]),e}();t.default=p},function(e,t,n){"use strict";function r(e){return e&&e.__esModule?e:{default:e}}Object.defineProperty(t,"__esModule",{value:!0});var o=n(10),i=r(o),u=n(11),s=r(u),a={registerProducers:function(e){e.forEach(function(e){return i.default.register(e)})},producerForKey:function(e){return i.default.producerForKey(e)},subscribe:function(e,t,n){var r=arguments.length>3&&void 0!==arguments[3]?arguments[3]:{},o=new s.default(e,n,r),i=this.producerForKey(t);i.addComponent(o)},unsubscribe:function(e,t){var n=this.producerForKey(t);n.removeComponent(e)},unsubscribeAll:function(e){i.default.producers.forEach(function(t){return t.prototype.getInstance().removeComponent(e)})}};t.default=a},function(e,t){"use strict";Object.defineProperty(t,"__esModule",{value:!0});var n=[],r={},o="There are no producers registered - register producers through the ProducerManager",i=function(e){return"No producer found for subscription "+e+"!"},u=function(e){return"A producer for the key "+e+" is already registered"},s={producers:n,producerClassForKey:function(e){var t=e.key;if(0===n.length)throw o;var u=r[t];if(!u)throw i(t);return u},producerForKey:function(e){var t=this.producerClassForKey(e);return t.prototype.getInstance()},register:function(e){if(n.indexOf(e)===-1){n.push(e);var t=e.prototype.PRODUCTION_KEY,o=t.key;if(r[o])throw u(o);return r[o]=e}},reset:function(){return n.length=0,r={}}};t.default=s},function(e,t){"use strict";function n(e,t){if(!(e instanceof t))throw new TypeError("Cannot call a class as a function")}Object.defineProperty(t,"__esModule",{value:!0});var r=function e(t,r,o){n(this,e),this.id=t,this.callback=r,this.options=o};t.default=r},function(e,t,n){"use strict";function r(e){return e&&e.__esModule?e:{default:e}}Object.defineProperty(t,"__esModule",{value:!0});var o="function"==typeof Symbol&&"symbol"==typeof Symbol.iterator?function(e){return typeof e}:function(e){return e&&"function"==typeof Symbol&&e.constructor===Symbol&&e!==Symbol.prototype?"symbol":typeof e},i=n(2),u=r(i),s=n(13),a=function(e,t,n){var r=arguments.length>3&&void 0!==arguments[3]?arguments[3]:"recieving";if(s.settings.shouldValidateContract){if(!e)throw new Error("The "+n+" does not have any contract specified");if(!t)throw new Error(n+" is trying to validate the contract but does not recieve any data to compare against the contract");if(u.default.isArray(e)&&u.default.isArray(t)===!1)throw new Error(n+"'s compared data is supposed to be an array but is a "+("undefined"==typeof t?"undefined":o(t)));if(u.default.isObject(e)&&u.default.isArray(e)===!1&&u.default.isArray(t))throw new Error(n+"'s compared data is supposed to be an object but is an array");if(u.default.isObject(e)&&u.default.isArray(e)===!1){var i=u.default.keys(e).length,a=u.default.keys(t).length;if(a>i)throw new Error(n+" is "+r+" more data then what is specified in the contract",e,t);if(a<i)throw new Error(n+" is "+r+" less data then what is specified in the contract",e,t)}for(var c in e)if(e.hasOwnProperty(c)){var l=e[c];if(!(c in t))throw new Error(n+" has data but is missing the key: "+c);if((null!==l||void 0!==l)&&o(t[c])!==("undefined"==typeof l?"undefined":o(l)))throw new Error(n+" is "+r+" data of the wrong type according to the contract, "+c+", expects "+("undefined"==typeof l?"undefined":o(l))+" but gets "+o(t[c]))}return!0}};t.default=a},function(e,t,n){"use strict";function r(e){return e&&e.__esModule?e:{default:e}}function o(e){u.default.extend(s,e)}Object.defineProperty(t,"__esModule",{value:!0}),t.setup=t.settings=void 0;var i=n(2),u=r(i),s={shouldValidateContract:!1};t.settings=s,t.setup=o},function(e,t,n){"use strict";function r(e){return e&&e.__esModule?e:{default:e}}function o(e,t){if(!(e instanceof t))throw new TypeError("Cannot call a class as a function")}Object.defineProperty(t,"__esModule",{value:!0});var i=function(){function e(e,t){for(var n=0;n<t.length;n++){var r=t[n];r.enumerable=r.enumerable||!1,r.configurable=!0,"value"in r&&(r.writable=!0),Object.defineProperty(e,r.key,r)}}return function(t,n,r){return n&&e(t.prototype,n),r&&e(t,r),t}}(),u=n(2),s=r(u),a=n(3),c=function(){function e(t,n,r,i){o(this,e),this._window=t,this.service=r,this.name=n,this.subscribers=i,this.pollingInterval=void 0,this.lastPollTime=void 0,this.timeout=void 0,this.params=this.getParams(),this.restart()}return i(e,[{key:"restart",value:function(){var e=void 0,t=!("undefined"==typeof this.lastPollTime||null===this.lastPollTime);if(this.pollingInterval=this.getPollingInterval(),t){var n=this._window.Date.now()-this.lastPollTime;e=Math.max(this.pollingInterval-n,0)}else e=0;this.setupNextFetch(e)}},{key:"stop",value:function(){this._window.clearTimeout(this.timeout),this.timeout=void 0,this.subscribers=void 0,this.params=void 0,this.service.removeChannel(this)}},{key:"setupNextFetch",value:function(){var e=this,t=arguments.length>0&&void 0!==arguments[0]?arguments[0]:this.pollingInterval;this._window.clearTimeout(this.timeout),this.timeout=this._window.setTimeout(function(){e.lastPollTime=e._window.Date.now(),e.service.fetch(e.params),e.cullImmediateRequests(),e.subscribers&&(e.pollingInterval>0?e.setupNextFetch():e.timeout=void 0)},t)}},{key:"addSubscription",value:function(e){s.default.includes(this.subscribers,e)||(this.subscribers.push(e),this.onSubscriptionsChanged())}},{key:"removeSubscription",value:function(e){s.default.includes(this.subscribers,e)&&(this.subscribers=s.default.without(this.subscribers,e),0===this.subscribers.length?this.stop():this.onSubscriptionsChanged())}},{key:"onSubscriptionsChanged",value:function(){var e=this.getParams(),t=!s.default.isEqual(e,this.params),n=this.params;this.params=e;var r=!1;t&&(r=this.service.shouldFetchOnParamsUpdate(this.params,n,this.name)),r?(this.lastPollTime=void 0,this.restart()):this.getPollingInterval()!==this.pollingInterval&&this.restart()}},{key:"getPollingInterval",value:function(){var e=s.default.map(this.subscribers,function(e){return e.pollingInterval}),t=s.default.min(e);return t===1/0?0:t}},{key:"getParams",value:function(){var e=s.default.map(this.subscribers,function(e){return e.params});return e=s.default.compact(e),this.service.consolidateParams(e,this.name)}},{key:"cullImmediateRequests",value:function(){var e=this,t=s.default.filter(this.subscribers,function(e){return void 0===e.pollingInterval||0===e.pollingInterval});s.default.each(t,function(t){return e.removeSubscription(t)}),this.pollingInterval=this.getPollingInterval()}}]),e}(),l=function(){function e(){var t=arguments.length>0&&void 0!==arguments[0]?arguments[0]:window;o(this,e);var n=this;this.channels={},this._window=t,this.Model=a.Model.extend({sync:function(e,t,r){return n.sync(e,t,r)},url:function(){return n.url(this)},parse:function(e,t){return n.parse(e,t,this)}})}return i(e,null,[{key:"extend",get:function(){return a.Model.extend}}]),i(e,[{key:"consolidateParams",value:function(e){return e[0]}},{key:"channelForParams",value:function(e){return JSON.stringify(e)||"{}"}},{key:"shouldFetchOnParamsUpdate",value:function(){return!0}},{key:"onFetchSuccess",value:function(){}},{key:"onFetchError",value:function(){}},{key:"onPostSuccess",value:function(){}},{key:"onPostError",value:function(){}},{key:"onPutSuccess",value:function(){}},{key:"onPutError",value:function(){}},{key:"onDeleteSuccess",value:function(){}},{key:"onDeleteError",value:function(){}},{key:"sync",value:function(e,t,n){return a.Model.prototype.sync.call(t,e,t,n)}},{key:"url",value:function(e){a.Model.prototype.url.call(e)}},{key:"parse",value:function(e,t,n){a.Model.prototype.parse.call(n)}},{key:"removeChannel",value:function(e){delete this.channels[e.name]}},{key:"addSubscription",value:function(e){var t=e.method||"GET";switch(t){case"GET":return this.addGetSubscription(e);case"POST":return this.post(e.postParams);case"PUT":return this.put(e.putParams);case"DELETE":return this.delete(e.deleteParams)}}},{key:"addGetSubscription",value:function(e){var t=this.channelForParams(e.params),n=this.channels[t];n?n.addSubscription(e):this.channels[t]=new c(this._window,t,this,[e])}},{key:"removeSubscription",value:function(e){if(e){var t=this.channelForParams(e.params),n=this.channels[t];n&&n.removeSubscription(e)}}},{key:"getModelInstance",value:function(e){return new this.Model(e)}},{key:"propagateResponse",value:function(e,t){return this.trigger(e,t)}},{key:"fetch",value:function(e){var t=this.getModelInstance(e);return t.fetch({success:this.onFetchSuccess,error:this.onFetchError})}},{key:"post",value:function(e){var t=this.getModelInstance(e);return t.save(void 0,{success:this.onPostSuccess,error:this.onPostError})}},{key:"put",value:function(e){var t=this.getModelInstance(e);if(!t.get("id"))throw"PUT requests must have an id specified in putParams";return t.save(void 0,{success:this.onPutSuccess,error:this.onPutError})}},{key:"delete",value:function(e){var t=this.getModelInstance(e);return t.destroy({success:this.onDeleteSuccess,error:this.onDeleteError})}}]),e}();s.default.extend(l.prototype,a.Events),t.default=l},function(e,t,n){"use strict";function r(e){return e&&e.__esModule?e:{default:e}}function o(e,t){if(!(e instanceof t))throw new TypeError("Cannot call a class as a function")}function i(e,t){if(!e)throw new ReferenceError("this hasn't been initialised - super() hasn't been called");return!t||"object"!=typeof t&&"function"!=typeof t?e:t}function u(e,t){if("function"!=typeof t&&null!==t)throw new TypeError("Super expression must either be null or a function, not "+typeof t);e.prototype=Object.create(t&&t.prototype,{constructor:{value:e,enumerable:!1,writable:!0,configurable:!0}}),t&&(Object.setPrototypeOf?Object.setPrototypeOf(e,t):e.__proto__=t)}Object.defineProperty(t,"__esModule",{value:!0});var s="function"==typeof Symbol&&"symbol"==typeof Symbol.iterator?function(e){return typeof e}:function(e){return e&&"function"==typeof Symbol&&e.constructor===Symbol&&e!==Symbol.prototype?"symbol":typeof e},a=function(){function e(e,t){for(var n=0;n<t.length;n++){var r=t[n];r.enumerable=r.enumerable||!1,r.configurable=!0,"value"in r&&(r.writable=!0),Object.defineProperty(e,r.key,r)}}return function(t,n,r){return n&&e(t.prototype,n),r&&e(t,r),t}}(),c=n(2),l=r(c),f=n(16),d=r(f),p=function(e){function t(){o(this,t);var e=i(this,(t.__proto__||Object.getPrototypeOf(t)).apply(this,arguments));return e.updatedIds=[],e.subscriptions={},e}return u(t,e),a(t,[{key:"idType",get:function(){return this._idType||s(0)},set:function(e){this._idType=e}}]),a(t,[{key:"subscribe",value:function(e){var t=this.idForOptions(e);if(!this.isIdOfValidType(t))throw"expected the subscription key to be a "+this.idType+" but got a "+("undefined"==typeof t?"undefined":s(t));return this.subscriptions[t]?this.subscriptions[t].push(e):this.subscriptions[t]=[e],this.produceDataSync(t)}},{key:"isIdOfValidType",value:function(e){return("undefined"==typeof e?"undefined":s(e))===this.idType}},{key:"onDiffInRepository",value:function(e,t){var n=this,r=function(t){var r=n.idForModel(t,e);return l.default.isArray(r)?l.default.filter(r,n.hasId.bind(n)):n.hasId(r)?r:void 0},o=function(t){if(n.shouldPropagateModelChange(t,e)){var r=n.idForModel(t,e);if(l.default.isArray(r))return l.default.filter(r,n.hasId.bind(n));if(n.hasId(r))return r}},i=l.default.map(t.added,r),u=l.default.map(t.removed,r),s=l.default.map(t.changed,o),a=l.default.flattenDepth([i,u,s],2);a=l.default.compact(a),this.produceDataForIds(a)}},{key:"produceDataForIds",value:function(){var e=arguments.length>0&&void 0!==arguments[0]?arguments[0]:this.allIds();return this.updatedIds=l.default.uniq(this.updatedIds.concat(e)),this.produceData()}},{key:"allIds",value:function(){var e=l.default.keys(this.subscriptions);return this.idType===s(0)&&(e=l.default.map(e,function(e){return parseInt(e,10)})),e}},{key:"produceDataSync",value:function(e){if(e)return this.produce([e]);if(this.updatedIds.length>0){var t=this.updatedIds.slice();return this.updatedIds.length=0,this.produce(t)}}},{key:"unsubscribe",value:function(e){var t=this.idForOptions(e),n=this.subscriptions[t];if(n){var r=n.indexOf(e);r!==-1&&(n.splice(r,1),0===n.length&&delete this.subscriptions[t])}}},{key:"produce",value:function(e){var t=this,n=void 0;e.forEach(function(e){n=t.currentData(e)||{},n.id=e,n=t.decorate(n),t._validateContract(n),l.default.each(t.registeredComponents,function(r){if(e===t.idForOptions(r.options))return r.callback(n)})})}},{key:"currentData",value:function(){}},{key:"hasId",value:function(e){return!(null===this.subscriptions[e]||"undefined"==typeof this.subscriptions[e])}},{key:"shouldPropagateModelChange",value:function(){return!0}},{key:"idForModel",value:function(e){return e.id}},{key:"idForOptions",value:function(e){return e.id}}]),t}(d.default);t.default=p},function(e,t,n){"use strict";function r(e){return e&&e.__esModule?e:{default:e}}function o(e,t){if(!(e instanceof t))throw new TypeError("Cannot call a class as a function")}Object.defineProperty(t,"__esModule",{value:!0});var i=function(){function e(e,t){for(var n=0;n<t.length;n++){var r=t[n];r.enumerable=r.enumerable||!1,r.configurable=!0,"value"in r&&(r.writable=!0),Object.defineProperty(e,r.key,r)}}return function(t,n,r){return n&&e(t.prototype,n),r&&e(t,r),t}}(),u=n(2),s=r(u),a=n(3),c=n(17),l=r(c),f=n(12),d=r(f),p=function(){function e(){o(this,e),this.onDiffInRepository=this.onDiffInRepository.bind(this),this.registeredComponents={},this.produceData=s.default.throttle(this.produceDataSync,100),this._isSubscribedToRepositories=!1}return i(e,[{key:"PRODUCTION_KEY",get:function(){return this._productionKey},set:function(e){this._productionKey=e}},{key:"repositories",get:function(){return this._repositories||[]},set:function(e){this._repositories=e}},{key:"decorators",get:function(){return this._decorators||[]},set:function(e){this._decorators=e}}],[{key:"extend",get:function(){return a.Model.extend}}]),i(e,[{key:"getInstance",value:function(){return null!==this.instance&&"undefined"!=typeof this.instance||(this.instance=new this.constructor),this.instance}},{key:"addComponent",value:function(e){var t=this.registeredComponents[e.id];null!==t&&"undefined"!=typeof t||(this.registeredComponents[e.id]=e,this.subscribe(e.options),this._isSubscribedToRepositories||(this.subscribeToRepositories(),this._isSubscribedToRepositories=!0))}},{key:"removeComponent",value:function(e){var t=this.registeredComponents[e];if(t){this.unsubscribe(t.options),delete this.registeredComponents[t.id];var n=!0;for(var r in this.registeredComponents)if(this.registeredComponents.hasOwnProperty(r)){n=!1;break}n&&(this.unsubscribeFromRepositories(),this._isSubscribedToRepositories=!1)}}},{key:"subscribeToRepositories",value:function(){var e=this;this.repositories.forEach(function(t){if(t instanceof l.default)e.subscribeToRepository(t);else{if(!(t.repository instanceof l.default&&"string"==typeof t.callback))throw"unexpected format of producer repositories definition";e.subscribeToRepository(t.repository,e[t.callback])}})}},{key:"unsubscribeFromRepositories",value:function(){var e=this;this.repositories.forEach(function(t){t instanceof l.default?e.unsubscribeFromRepository(t):t.repository instanceof l.default&&"string"==typeof t.callback&&e.unsubscribeFromRepository(t.repository)})}},{key:"subscribeToRepository",value:function(e,t){var n=this;t||(t=function(t){return n.onDiffInRepository(e,t)}),this.listenTo(e,l.default.prototype.REPOSITORY_DIFF,t)}},{key:"unsubscribeFromRepository",value:function(e){this.stopListening(e,l.default.prototype.REPOSITORY_DIFF)}},{key:"subscribe",value:function(){this.produceDataSync()}},{key:"onDiffInRepository",value:function(){this.produceData()}},{key:"produceDataSync",value:function(){this.produce(this.currentData())}},{key:"produce",value:function(e){e=this.decorate(e),this._validateContract(e);for(var t in this.registeredComponents)if(this.registeredComponents.hasOwnProperty(t)){var n=this.registeredComponents[t];n.callback(e)}}},{key:"currentData",value:function(){}},{key:"unsubscribe",value:function(){}},{key:"decorate",value:function(e){for(var t=0;t<this.decorators.length;t++){var n=this.decorators[t];n(e)}return e}},{key:"modelToJSON",value:function(e){return e.toJSON()}},{key:"modelsToJSON",value:function(e){return s.default.map(e,this.modelToJSON)}},{key:"_validateContract",value:function(e){var t=this.PRODUCTION_KEY,n=t.key,r=t.contract;if(!r)throw new Error("The subscriptionKey "+n+" doesn't have a contract specified");(0,d.default)(r,e,this,"producing")}},{key:"extend",value:function(e,t){for(var n in t)if(t.hasOwnProperty(n)){var r=t[n];e[n]=r}return e}},{key:"mixin",value:function(e,t){return this.extend(e,t)}}]),e}();s.default.extend(p.prototype,a.Events),t.default=p},function(e,t,n){"use strict";function r(e){return e&&e.__esModule?e:{default:e}}function o(e,t){if(!(e instanceof t))throw new TypeError("Cannot call a class as a function")}function i(e,t){if(!e)throw new ReferenceError("this hasn't been initialised - super() hasn't been called");return!t||"object"!=typeof t&&"function"!=typeof t?e:t}function u(e,t){if("function"!=typeof t&&null!==t)throw new TypeError("Super expression must either be null or a function, not "+typeof t);e.prototype=Object.create(t&&t.prototype,{constructor:{value:e,enumerable:!1,writable:!0,configurable:!0}}),t&&(Object.setPrototypeOf?Object.setPrototypeOf(e,t):e.__proto__=t)}Object.defineProperty(t,"__esModule",{value:!0});var s=function e(t,n,r){null===t&&(t=Function.prototype);var o=Object.getOwnPropertyDescriptor(t,n);if(void 0===o){var i=Object.getPrototypeOf(t);return null===i?void 0:e(i,n,r)}if("value"in o)return o.value;var u=o.get;if(void 0!==u)return u.call(r)},a=function(){function e(e,t){for(var n=0;n<t.length;n++){var r=t[n];r.enumerable=r.enumerable||!1,r.configurable=!0,"value"in r&&(r.writable=!0),Object.defineProperty(e,r.key,r)}}return function(t,n,r){return n&&e(t.prototype,n),r&&e(t,r),t}}(),c=n(2),l=r(c),f=n(3),d=function(e){function t(){var e;o(this,t);for(var n=arguments.length,r=Array(n),u=0;u<n;u++)r[u]=arguments[u];var s=i(this,(e=t.__proto__||Object.getPrototypeOf(t)).call.apply(e,[this].concat(r)));return s._onAdd=s._onAdd.bind(s),s._onChange=s._onChange.bind(s),s._onRemove=s._onRemove.bind(s),s._triggerUpdates=s._triggerUpdates.bind(s),s}return u(t,e),a(t,[{key:"REPOSITORY_DIFF",get:function(){return"repository_diff"}},{key:"REPOSITORY_ADD",get:function(){return"repository_add"}},{key:"REPOSITORY_CHANGE",get:function(){return"repository_change"}},{key:"REPOSITORY_REMOVE",get:function(){return"repository_remove"}}]),a(t,[{key:"initialize",value:function(){s(t.prototype.__proto__||Object.getPrototypeOf(t.prototype),"initialize",this).apply(this,arguments),this.cid=this.cid||l.default.uniqueId("c"),this._throttledAddedModels={},this._throttledChangedModels={},this._throttledRemovedModels={},this._throttledTriggerUpdates=l.default.throttle(this._triggerUpdates,100,{leading:!1}),this.addThrottledListeners()}},{key:"addThrottledListeners",value:function(){this.on("all",this._onAll)}},{key:"getByIds",value:function(e){for(var t=[],n=0;n<e.length;n++){var r=e[n];t.push(this.get(r))}return t}},{key:"isEmpty",value:function(){return this.models.length<=0}},{key:"_onAll",value:function(e,t){switch(e){case"add":this._onAdd(t);break;case"change":this._onChange(t);break;case"remove":this._onRemove(t)}this._throttledTriggerUpdates()}},{key:"_onAdd",value:function(e){this._throttledAddedModels[e.id]=e}},{key:"_onChange",value:function(e){this._throttledChangedModels[e.id]=e}},{key:"_onRemove",value:function(e){this._throttledRemovedModels[e.id]=e}},{key:"_throttledAdd",value:function(){var e=t.prototype.REPOSITORY_ADD,n=l.default.values(this._throttledAddedModels);return this._throttledAddedModels={},this._throttledEvent(e,n,e)}},{key:"_throttledChange",value:function(){var e=t.prototype.REPOSITORY_CHANGE,n=l.default.values(this._throttledChangedModels);return this._throttledChangedModels={},this._throttledEvent(e,n,e)}},{key:"_throttledRemove",value:function(){var e=t.prototype.REPOSITORY_REMOVE,n=l.default.values(this._throttledRemovedModels);return this._throttledRemovedModels={},this._throttledEvent(e,n,e)}},{key:"_throttledEvent",value:function(e,t,n){return t.length>0&&this.trigger(e,t,n),t}},{key:"_throttledDiff",value:function(e,n,r){var o=t.prototype.REPOSITORY_DIFF;if(e.length||n.length||r.length){e=l.default.difference(e,r);var i=l.default.uniq(e.concat(n)),u={added:e,changed:n,removed:r,consolidated:i};this.trigger(o,u,o)}}},{key:"_triggerUpdates",value:function(){this._throttledDiff(this._throttledAdd(),this._throttledChange(),this._throttledRemove())}}]),t}(f.Collection);t.default=d},function(e,t,n){"use strict";function r(e){return e&&e.__esModule?e:{default:e}}function o(e,t){if(!(e instanceof t))throw new TypeError("Cannot call a class as a function")}function i(e,t){if(!e)throw new ReferenceError("this hasn't been initialised - super() hasn't been called");return!t||"object"!=typeof t&&"function"!=typeof t?e:t}function u(e,t){if("function"!=typeof t&&null!==t)throw new TypeError("Super expression must either be null or a function, not "+typeof t);e.prototype=Object.create(t&&t.prototype,{constructor:{value:e,enumerable:!1,writable:!0,configurable:!0}}),t&&(Object.setPrototypeOf?Object.setPrototypeOf(e,t):e.__proto__=t)}Object.defineProperty(t,"__esModule",{value:!0});var s=function(){function e(e,t){for(var n=0;n<t.length;n++){var r=t[n];r.enumerable=r.enumerable||!1,r.configurable=!0,"value"in r&&(r.writable=!0),Object.defineProperty(e,r.key,r)}}return function(t,n,r){return n&&e(t.prototype,n),r&&e(t,r),t}}(),a=n(17),c=r(a),l=function(e){function t(){return o(this,t),i(this,(t.__proto__||Object.getPrototypeOf(t)).apply(this,arguments))}return u(t,e),s(t,[{key:"addSubscriptionToService",value:function(e,t){e.addSubscription(t)}},{key:"removeSubscriptionFromService",value:function(e,t){e.removeSubscription(t)}},{key:"addSubscription",value:function(e,t){this.services[e]&&this.addSubscriptionToService(this.services[e],t)}},{key:"removeSubscription",value:function(e,t){this.services[e]&&this.removeSubscriptionFromService(this.services[e],t)}},{key:"services",get:function(){return this._services||{}},set:function(e){this._services=e}}]),t}(c.default);t.default=l}])});
//# sourceMappingURL=vigor.js.map