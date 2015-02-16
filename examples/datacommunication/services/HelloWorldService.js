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
      setTimeout(_.bind(function () {
        var response = [
          {
            'id': 'dummy',
            'message': 'im a change',
            'count': 100
          },
          {
            'id': 'rummy',
            'message': 'im added',
            'count': 5
          },
          {
            'id': 'summy',
            'message': 'im also added',
            'count': 3
          }
        ]
        this.parse(response);
      }, this), 12500);
    },

    parse: function (response) {
      var models;
      Vigor.ApiService.prototype.parse.call(this, response);
      if (Array.isArray(response)) {
        this.repository.set(response)
      } else {
        models = this._buildHelloWorldModels(response);
        this.repository.set(models)
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
