var app = app || {};

(function ($) {
  'use strict';
  var SubscriptionKeys = Vigor.SubscriptionKeys;
  app.HelloWorldViewModel = Vigor.ViewModel.extend({

    id: 'HelloWorldViewModel',
    helloWorldId: undefined,
    helloWorld: undefined,

    constructor: function (helloWorldId) {
      if (helloWorldId) {
        this.helloWorldId = helloWorldId;
      }
      Vigor.ViewModel.prototype.constructor.apply(this, arguments);
      this.helloWorld = new Backbone.Model();
    },

    addSubscriptions: function () {
      this.subscribe(SubscriptionKeys.HELLO_WORLD_BY_ID, this._onChangedById, { id: this.helloWorldId });
    },

    removeSubscriptions: function () {
      this.unsubscribe(SubscriptionKeys.HELLO_WORLD_BY_ID)
    },

    _onHelloWorldItemsChanged: function (jsonData) {
      console.log('just set some data: ', jsonData)
      this.helloWorld.set(jsonData, {add: false, remove: false, merge: true});
    }

  });
})(jQuery);
