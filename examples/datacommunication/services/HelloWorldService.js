var app = app || {};

(function ($) {
  'use strict';

  var HelloWorldService = Vigor.ApiService.extend({

    count: 0,
    repository: undefined,
    url: './examples/datacommunication/services/helloWorld.json',

    NAME: 'HelloWorldService',

    constructor: function (helloWorldRepository) {
      Vigor.ApiService.prototype.constructor.call(this, helloWorldRepository, 5000);
    },

    parse: function (response) {
      Vigor.ApiService.prototype.parse.call(this, response);
      if (Array.isArray(response)) {
        this.repository.set(response)
      } else {
        this.repository.set(this._buildHelloWorldModels(response))
      }
    },

    _buildHelloWorldModels: function (response) {
      var models;
      this.count++;
      models = [{
          'id': 'dummy',
          'message': response.message,
          'count': this.count
        },
        {
          'id': 'tummy',
          'message': 'im going to be removed',
          'count': 0
        }
      ]
      return models;
    }
  });

  app.HelloWorldService = new HelloWorldService(app.HelloWorldRepository)

})(jQuery);
