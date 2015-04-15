var app = app || {};

(function ($) {
  'use strict';

  var SubscriptionKeys = Vigor.SubscriptionKeys,
      HelloWorldRepository = app.HelloWorldRepository;

  app.HelloWorldProducer = Vigor.IdProducer.extend({

    PRODUCTION_KEY: SubscriptionKeys.HELLO_WORLD,
    repositories: [HelloWorldRepository],

    idType: typeof "",

    decorators: [
      function(data) {
        $.extend(data, HelloWorldRepository.get(data.id).toJSON());
        return data;
      }
    ]
  });

})(jQuery);
