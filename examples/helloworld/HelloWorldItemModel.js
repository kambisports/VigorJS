var app = app || {};

(function ($) {
  'use strict';
  app.HelloWorldItemModel = Backbone.Model.extend({
    defaults: {
      id: '',
      message: '',
      count: 0
    }
  });
})(jQuery);
