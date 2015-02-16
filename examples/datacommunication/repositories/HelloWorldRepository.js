var app = app || {};

(function ($) {
  'use strict';

  var HelloWorldService = app.HelloWorldService;

  var HelloWorldRepository = Vigor.ServiceRepository.extend({

    initialize: function () {
      HelloWorldService.on(HelloWorldService.HELLO_WORLDS_RECEIVED, _.bind(this._onHelloWorldsReceived, this));
      Vigor.ServiceRepository.prototype.initialize.call(this, arguments);
    },

    fetchHelloWorlds: function () {
      // this.callApiService(HelloWorldService.NAME, {});
      HelloWorldService.run({});
      return this.getHelloWorlds();
    },

    fetchById: function (id) {
      // this.callApiService(HelloWorldService.NAME, { id: id });
      HelloWorldService.run({ id: id });
      return this.get(id)
    },

    getHelloWorlds: function () {
      return this.models;
    },

    _onHelloWorldsReceived: function (models) {
      this.set(models);
    },

    makeTestInstance: function () {
      return new HelloWorldRepository();
    }

  });

  app.HelloWorldRepository = new HelloWorldRepository()

})(jQuery);
