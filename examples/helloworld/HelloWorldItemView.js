var app = app || {};

(function ($) {
  'use strict';
  app.HelloWorldItemView = Vigor.ComponentView.extend({

    tagName: 'li',
    className: 'hello-world-item',

    initialize: function (options) {
      Vigor.ComponentView.prototype.initialize.call(this, options);
      this.listenTo(this.viewModel.helloWorld, 'change', this._onHelloWorldItemChanged);
    },

    renderStaticContent: function () {
      tmpl = "render static";
      this.$el.html(tmpl);
      return this;
    },

    renderDynamicContent: function () {
      this.$el.html('dynamic');
      return this;
    },

    addSubscriptions: function () {
      this.viewModel.addSubscriptions();
    },

    removeSubscriptions: function () {
      this.viewModel.removeSubscriptions();
    },

    dispose: function () {
      this.stopListening();
      Vigor.ComponentView.prototype.dispose.call(this, null);
    },

    _onHelloWorldItemChanged: function () {
      this.renderDynamicContent();
    }
  });
})(jQuery);
