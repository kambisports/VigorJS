var app = app || {};

Vigor.SubscriptionKeys.extend({
  HELLO_WORLDS: 'hello-worlds'
});

(function ($) {
  'use strict';
  app.HelloWorldProducer = Vigor.Producer.extend({

    constructor: function (options) {
      Vigor.Producer.prototype.constructor.call(this, options);
    }

  });

  app.helloWorldProducer.prototype.SUBSCRIPTION_KEYS = [Vigor.SubscriptionKeys.HELLO_WORLDS];
  console.log(app.HelloWorldProducer.prototype);
})(jQuery);
