var app = app || {};

(function ($) {
  'use strict';
  app.HelloWorldItemViewModel = Vigor.ComponentViewModel.extend({

    id: 'HelloWorldItemViewModel',
    helloWorldId: undefined,
    helloWorld: undefined,

    constructor: function (helloWorldId) {
      Vigor.ComponentViewModel.prototype.constructor.call(this, arguments);
      this.helloWorldId = helloWorldId;
      this.helloWorld = new app.HelloWorldItemModel();
    },

    addSubscriptions: function () {
      this.subscribe(Vigor.SubscriptionKeys.HELLO_WORLD, _.bind(this._onChangedById, this), { id: this.helloWorldId });
    },

    removeSubscriptions: function () {
      this.unsubscribe(Vigor.SubscriptionKeys.HELLO_WORLD);
    },

    _onChangedById: function (jsonData) {
      Vigor.ComponentViewModel.prototype.validateContract.apply(this, [this.helloWorld.defaults, jsonData]);
      this.helloWorld.set(jsonData, { add: false, remove: false, merge: true })
    }

  });
})(jQuery);
