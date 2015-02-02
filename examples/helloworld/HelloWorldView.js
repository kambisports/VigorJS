var app = app || {};

(function ($) {
  'use strict';
  app.HelloWorldView = Vigor.ComponentView.extend({

    className: 'hello-world',

    constructor: function (options) {
      Vigor.ComponentView.prototype.constructor.call(this, options);
    },

    initialize: function (options) {
      Vigor.ComponentView.prototype.initialize.call(this, options);
    },

    renderStaticContent: function () {
      this.$el.html('hej')
    },

    renderDynamicContent: function () {},

    addSubscriptions: function () {
      this.viewModel.addSubscriptions();
    },

    removeSubscriptions: function () {},

    dispose: function () {}

  });
})(jQuery);
