var app = app || {};

(function ($) {
  'use strict';

  Vigor.SubscriptionKeys.extend({
    HELLO_WORLDS: 'hello-worlds',
    HELLO_WORLD_BY_ID: 'hello-world-by-id'
  });

  var HelloWorldRepository = app.HelloWorldRepository;

  app.HelloWorldProducer = Vigor.Producer.extend({

    SUBSCRIPTION_KEYS: [
      Vigor.SubscriptionKeys.HELLO_WORLDS,
      Vigor.SubscriptionKeys.HELLO_WORLD_BY_ID
    ],

    NAME: 'HelloWorldProducer',

    constructor: function (options) {
      Vigor.Producer.prototype.constructor.call(this, options);
      HelloWorldRepository.on(HelloWorldRepository.REPOSITORY_DIFF, this._onDiffInRepository, this)
    },

    subscribe: function (subscriptionKey, options) {
      HelloWorldRepository.interestedInUpdates(this.NAME);

      switch (subscriptionKey) {
        case Vigor.SubscriptionKeys.HELLO_WORLDS:
          this._produceHelloWorlds();
          break;
        case Vigor.SubscriptionKeys.HELLO_WORLD_BY_ID:
          var model = HelloWorldRepository.queryById(options.id);
          this._produceData(subscriptionKey, [model]);
          break;
        default:
          throw new Error("Unknown query subscriptionKey: " + key);
      }
    },

    dispose: function () {
      HelloWorldRepository.off(HelloWorldRepository.REPOSITORY_DIFF, this._onDiffInRepository, this)
      HelloWorldRepository.notInterestedInUpdates(this.NAME)
    },

    _produceHelloWorlds: function () {
      var models = HelloWorldRepository.queryHelloWorlds();
      this._produceData(Vigor.SubscriptionKeys.HELLO_WORLDS, models);
    },

    _produceData: function (subscriptionKey, models) {
      if (models == null) {
        models = [];
      }

      if (!(models.length > 0))
        return

      models = _.without(models, undefined);
      models = _.map(models, function (model) {
        return model.toJSON()
      });

      switch (subscriptionKey) {
        case Vigor.SubscriptionKeys.HELLO_WORLDS:
          this.produce(subscriptionKey, models);
          break;
        case Vigor.SubscriptionKeys.HELLO_WORLD_BY_ID:
          for (var i = 0; i < this.models.length; i ++) {
            this.produce(subscriptionKey, models, function (componentOptions) {
              return model.id === componentOptions.id
            });
          }
          break;
        default:
          throw new Error("Unknown query subscriptionKey: " + key);
      }

    },

    _onDiffInRepository: function (dataDiff) {

      if(dataDiff.added.length > 0 || dataDiff.removed.length > 0)
        this._produceHelloWorlds();

      if(dataDiff.changed.length > 0)
        this._produceData(Vigor.SubscriptionKeys.HELLO_WORLD_BY_ID, dataDiff.changed);
    }

  });

})(jQuery);
