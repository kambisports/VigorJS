var app = app || {};

(function ($) {
  'use strict';

  var HelloWorldRepository = app.HelloWorldRepository,
      SubscriptionKeys = Vigor.SubscriptionKeys;

  app.HelloWorldsProducer = Vigor.Producer.extend({

    PRODUCTION_KEY: SubscriptionKeys.HELLO_WORLDS,
    repositories: [HelloWorldRepository],

    repoFetchSubscription: undefined,

    subscribeToRepositories: function () {
      Vigor.Producer.prototype.subscribeToRepositories.call(this);

      this.repoFetchSubscription = {
        pollingInterval: 3000
      };

      HelloWorldRepository.addSubscription(HelloWorldRepository.ALL, this.repoFetchSubscription);
    },

    unsubscribeFromRepositories: function () {
      Vigor.Producer.prototype.unsubscribeFromRepositories.call(this);
      HelloWorldRepository.removeSubscription(HelloWorldRepository.ALL, this.repoFetchSubscription);
    },

    currentData: function () {
      var models = HelloWorldRepository.getHelloWorlds();

      models = _.without(models, undefined);
      models = this.modelsToJSON(models);
      return models;
    }

  });

})(jQuery);
