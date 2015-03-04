var app = app || {};

(function ($) {
  'use strict';

  var
  HelloWorldService = app.HelloWorldService,
  HelloWorldRepository = Vigor.ServiceRepository.extend({

    ALL: 'all',
    BY_ID: 'id',
    services: {
      'all': HelloWorldService,
      'id': HelloWorldService
    },

    initialize: function () {
      HelloWorldService.on(HelloWorldService.HELLO_WORLDS_RECEIVED, _.bind(this._onHelloWorldsReceived, this));
      Vigor.ServiceRepository.prototype.initialize.call(this, arguments);
    },

    getHelloWorlds: function () {
      return this.models;
    },

    _onHelloWorldsReceived: function (models) {
      this.set(models);
    }

  });

  app.HelloWorldRepository = new HelloWorldRepository();

})(jQuery);
