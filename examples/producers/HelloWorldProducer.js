var app = app || {};

(function ($) {
  'use strict';

  Vigor.SubscriptionKeys.extend({
    HELLO_WORLDS: 'hello-worlds'
  });

  app.HelloWorldProducer = Vigor.Producer.extend({

    SUBSCRIPTION_KEYS: [Vigor.SubscriptionKeys.HELLO_WORLDS],
    NAME: 'HelloWorldProducer',

    constructor: function (options) {
      Vigor.Producer.prototype.constructor.call(this, options);
      console.log(this);
    },

    subscribe: function () {
      app.HelloWorldRepository.interestedInUpdates(this.NAME);
    },

    dispose: function () {

    }

  });

})(jQuery);
