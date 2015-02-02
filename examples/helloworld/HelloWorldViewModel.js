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
      this.subscribe(SubscriptionKeys.HELLO_WORLDS);
    },

    removeSubscriptions: function () {},

    _onHelloWorldItemsChanged: function () {}

  });
})(jQuery);
