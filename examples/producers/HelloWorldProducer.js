var app = app || {};

(function ($) {
  'use strict';

  app.HelloWorldProducer = Vigor.Producer.extend({
    constructor: function () {
      console.log('im constructed');
    }
  });
});