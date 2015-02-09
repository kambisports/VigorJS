var app = app || {};

(function ($) {
  'use strict';

  var HelloWorldRepository = Vigor.ServiceRepository.extend({

    queryHelloWorlds: function () {
      if (!this.isEmpty()) {
        return this.models;
      }
      return [];
    },

    queryById: function (id) {
      this.get({'id': id});
    }

  });

  app.HelloWorldRepository = new HelloWorldRepository()

})(jQuery);
