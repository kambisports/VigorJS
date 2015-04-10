var app = app || {};

(function ($) {
  'use strict';

  var SubscriptionKeys = Vigor.SubscriptionKeys,
      HelloWorldRepository = app.HelloWorldRepository;

  app.HelloWorldProducer = Vigor.Producer.extend({

    PRODUCTION_KEY: SubscriptionKeys.HELLO_WORLD,

    subscribeToRepositories: function () {
      HelloWorldRepository.on(HelloWorldRepository.REPOSITORY_DIFF, this._onDiffInRepository, this);
    },

    unsubscribeFromRepositories: function () {
      HelloWorldRepository.off(HelloWorldRepository.REPOSITORY_DIFF, this._onDiffInRepository, this);
    },

    subscribe: function (options) {
      // If we want to send the id to the service and fetch something specific from the server

      // this.repoFetchSubscription = {
      //   pollingInterval: 3000
      //   params: {
      //    id: options.id
      //   }
      // };

      // HelloWorldRepository.addSubscription(HelloWorldRepository.BY_ID, this.repoFetchSubscription);

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
        model.hej = 'hej';
        this.produce(model, function (componentOptions) {
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
