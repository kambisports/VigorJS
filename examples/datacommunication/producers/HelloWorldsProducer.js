var app = app || {};

(function ($) {
  'use strict';

  var HelloWorldRepository = app.HelloWorldRepository,
      SubscriptionKeys = Vigor.SubscriptionKeys;

  app.HelloWorldsProducer = Vigor.Producer.extend({

    SUBSCRIPTION_KEYS: [
      SubscriptionKeys.HELLO_WORLDS
    ],

    NAME: 'HelloWorldsProducer',

    constructor: function (options) {
      Vigor.Producer.prototype.constructor.call(this, options);
      HelloWorldRepository.on(HelloWorldRepository.REPOSITORY_DIFF, this._onDiffInRepository, this)
    },

    dispose: function () {
      HelloWorldRepository.off(HelloWorldRepository.REPOSITORY_DIFF, this._onDiffInRepository, this)
    },

    subscribe: function (subscriptionKey, options) {
      HelloWorldRepository.fetchHelloWorlds();
      this._produceData();
    },

    _produceData: function () {
      this.produce(SubscriptionKeys.HELLO_WORLDS, this._buildData());
    },

    _buildData: function () {
      var models = HelloWorldRepository.getHelloWorlds();
      if (models.length <= 0)
        return

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
