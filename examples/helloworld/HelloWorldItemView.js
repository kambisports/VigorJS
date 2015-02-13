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
      var tmpl,
          helloWorld = this.viewModel.helloWorld.toJSON(),
          id = helloWorld.id,
          message = helloWorld.message,
          count = helloWorld.count;

      tmpl = "Item with id: " + id + ", message: " + message + ", and count: " + count;
      this.$el.html(tmpl);
      return this;
    },

    renderDynamicContent: function () {

      var tmpl,
          helloWorld = this.viewModel.helloWorld.toJSON(),
          id = helloWorld.id,
          message = helloWorld.message,
          count = helloWorld.count;

      tmpl = "Item with id: " + id + ", message: " + message + ", and count: " + count;
      this.$el.html(tmpl);
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
