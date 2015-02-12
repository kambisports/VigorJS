var app = app || {};

(function ($) {
  'use strict';
  app.HelloWorldItemModel = Vigor.ComponentView.extend({

    id: 'HelloWorldItemModel',
    helloWorldId: undefined,
    helloWorld: undefined,

    constructor: function (helloWorldId) {
      Vigor.ComponentView.prototype.constructor.call(this, arguments);
      this.helloWorldId = helloWorldId;
      this.helloWorld = new Backbone.Model();
    },

    addSubscriptions: function () {
      this.subscribe(Vigor.SubscriptionKeys.HELLO_WORLD_BY_ID, _.bind(this._onChangedById, this), { id: this.helloWorldId });
    },

    removeSubscriptions: function () {
      this.unsubscribe(Vigor.SubscriptionKeys.HELLO_WORLD_BY_ID);
    },

    _onChangedById: function (jsonData) {
      this.helloWorld.set(jsonData, { add: false, remove: false, merge: true })
    }

  });
})(jQuery);
