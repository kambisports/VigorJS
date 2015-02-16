var app = app || {};

(function ($) {
  'use strict';

  Vigor.SubscriptionKeys.extend({
    HELLO_WORLD: 'hello-world'
  });

  var SubscriptionKeys = Vigor.SubscriptionKeys,
      HelloWorldRepository = app.HelloWorldRepository;

  app.HelloWorldProducer = Vigor.Producer.extend({

    SUBSCRIPTION_KEYS: [
      Vigor.SubscriptionKeys.HELLO_WORLD
    ],

    NAME: 'HelloWorldProducer',

    constructor: function () {
      Vigor.Producer.prototype.constructor.call(this, arguments);
      HelloWorldRepository.on(HelloWorldRepository.REPOSITORY_DIFF, this._onDiffInRepository, this)
    },

    dispose: function () {
      HelloWorldRepository.off(HelloWorldRepository.REPOSITORY_DIFF, this._onDiffInRepository, this)
    },

    subscribe: function (subscriptionKey, options) {
      // If we want to send the id to the service and fetch something specific from the server
      // model = HelloWorldRepository.fetchById options.id

      // If we are only interested in already loaded models
      var model = HelloWorldRepository.get(options.id);
      this._produceData([model]);
    },

    _produceData: function (models) {
      if (models == null) {
        models = [];
      }

      if (!(models.length > 0))
        return

      models = _.without(models, undefined);
      models = this.modelsToJSON(models);

      for (var i = 0; i < models.length; i ++) {
        var model = models[i];
        this.produce(SubscriptionKeys.HELLO_WORLD, model, function (componentOptions) {
          return model.id === componentOptions.id
        });
      }
    },

    _onDiffInRepository: function (dataDiff) {
      if(dataDiff.changed.length > 0)
        this._produceData(dataDiff.changed);
    }

  });

})(jQuery);
