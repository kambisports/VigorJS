var app = app || {};

(function ($) {
  'use strict';

  var HelloWorldService = Vigor.ApiService.extend({

    this.count: 0,
    this.repository: undefined,

    constructor: function (helloWorldRepository) {
      Vigor.ApiService.prototype.constructor.call(this, helloWorldRepository, 5000);

    },

    parse: function (response) {
      Vigor.ApiService.prototype.parse.call(this, helloWorldRepository, 5000);
      if (Array.isArray(response)) {
        this.repository.set(response)
      } else {
        this.repository.set(this._buildHelloWorldModels(response))
      }

    },

    _buildHelloWorldModels: function (response) {
      this.count++;
      models = [{
          'id': 'dummy',
          'message': response.message,
          'count': @count
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
