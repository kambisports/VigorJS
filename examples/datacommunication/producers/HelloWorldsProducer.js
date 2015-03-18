var app = app || {};

(function ($) {
  'use strict';

  var HelloWorldRepository = app.HelloWorldRepository,
      SubscriptionKeys = Vigor.SubscriptionKeys;

  app.HelloWorldsProducer = Vigor.Producer.extend({

    SUBSCRIPTION_KEYS: [
      SubscriptionKeys.HELLO_WORLDS
    ],

    repoFetchSubscription: undefined,

    subscribeToRepositories: function () {
      HelloWorldRepository.on(HelloWorldRepository.REPOSITORY_DIFF, this._onDiffInRepository, this)

      this.repoFetchSubscription = {
        pollingInterval: 3000
      };

      HelloWorldRepository.addSubscription(HelloWorldRepository.ALL, this.repoFetchSubscription);
    },

    unsubscribeFromRepositories: function () {
      HelloWorldRepository.off(HelloWorldRepository.REPOSITORY_DIFF, this._onDiffInRepository, this)
      HelloWorldRepository.removeSubscription(HelloWorldRepository.ALL, this.repoFetchSubscription);
    },

    subscribe: function (subscriptionKey, options) {
      this._produceData();
    },

    _produceData: function () {
      this.produce(SubscriptionKeys.HELLO_WORLDS, this._buildData());
    },

    _buildData: function () {
      var models = HelloWorldRepository.getHelloWorlds();

      models = _.without(models, undefined);
      models = this.modelsToJSON(models);
      return models;
    },

    _onDiffInRepository: function (dataDiff) {
      if (dataDiff.added.length > 0 || dataDiff.removed.length > 0)
        this._produceData();
    }

  });

})(jQuery);
