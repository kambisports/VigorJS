var app = app || {};

(function ($) {
  'use strict';
  var SubscriptionKeys = Vigor.SubscriptionKeys;
  app.HelloWorldViewModel = Vigor.ViewModel.extend({

    id: 'HelloWorldViewModel',
    helloWorldItems: undefined,

    constructor: function () {
      Vigor.ViewModel.prototype.constructor.apply(this, arguments);
      this.helloWorldItems = new Backbone.Collection();
    },

    addSubscriptions: function () {
      this.subscribe(SubscriptionKeys.HELLO_WORLDS, _.bind(this._onHelloWorldItemsChanged, this), {});
    },

    removeSubscriptions: function () {
      this.unsubscribe(SubscriptionKeys.HELLO_WORLDS);
    },

    _onHelloWorldItemsChanged: function (jsonArray) {
      console.log(this, jsonArray);
      this.helloWorldItems.set(jsonArray, {add: true, remove: true, merge: false});
    }

  });
})(jQuery);
