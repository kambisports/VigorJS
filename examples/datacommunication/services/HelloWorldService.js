var app = app || {};

(function ($) {
  'use strict';

  var HelloWorldService = Vigor.APIService.extend({

    count: 0,
    NAME: 'HelloWorldService',
    HELLO_WORLDS_RECEIVED: 'hello-worlds-received',

    constructor: function () {
      Vigor.APIService.prototype.constructor.call(this);
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
        ];
        this.parse(response);
      }, this), 12500);
    },

    parse: function (response) {
      var models = [];
      Vigor.APIService.prototype.parse.call(this, response);
      if (Array.isArray(response)) {
        models = response;
      } else {
        models = this._buildHelloWorldModels(response);
      }
      this.propagateResponse(this.HELLO_WORLDS_RECEIVED, models);
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
      ];
      return models;
    },

    url: function () {
      return './datacommunication/services/helloWorld.json';
    }

  });

  app.HelloWorldService = new HelloWorldService();

})(jQuery);
