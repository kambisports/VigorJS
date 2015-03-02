var app = app || {};

(function ($) {
  'use strict';
  app.HelloWorldView = Vigor.ComponentView.extend({

    className: 'hello-world',
    $helloWorldItemsList: undefined,
    _helloWorldItems: undefined,

    constructor: function (options) {
      Vigor.ComponentView.prototype.constructor.call(this, options);
      this._helloWorldItems = [];

      this.listenTo(this.viewModel.helloWorldItems, 'add', this._onHelloWorldItemsAdd);
      this.listenTo(this.viewModel.helloWorldItems, 'remove', this._onHelloWorldItemsRemove);
    },

    initialize: function (options) {
      Vigor.ComponentView.prototype.initialize.call(this, options);
    },

    renderStaticContent: function () {
      var tmpl;
      tmpl = "Hello World component!";
      tmpl += "<ul class='modularized__hello-world-items-list'></ul>";
      this.$el.html(tmpl);

      this.$helloWorldItemsList = $('.modularized__hello-world-items-list', this.$el);
    },

    renderDynamicContent: function () {
      _.each(this._helloWorldItems, function (helloWorldItemView) {
        this.$helloWorldItemsList.append(helloWorldItemView.render().el);
      }, this);
    },

    addSubscriptions: function () {
      this.viewModel.addSubscriptions();
    },

    removeSubscriptions: function () {
      this.viewModel.removeSubscriptions();
    },

    dispose: function () {
      _.invoke(this._helloWorldItems, 'dispose');
      _.helloWorldItems = undefined;
      this.$helloWorldItemsList.remove();
      this.stopListening();
      Vigor.ComponentView.prototype.dispose.call(this, null);
    },

    _onHelloWorldItemsAdd: function (addedItem, collection, options) {
      var helloWorldItemModel = new app.HelloWorldItemViewModel(addedItem.id),
          helloWorldItemView = new app.HelloWorldItemView({ viewModel: helloWorldItemModel });

      this._helloWorldItems.push(helloWorldItemView);
      this.renderDynamicContent();
    },

    _onHelloWorldItemsRemove: function (removedItem, collection, options) {
      var removedComponent = this._helloWorldItems.splice(options.index, 1)[0];

      if (removedComponent) {
        removedComponent.el.remove();
        removedComponent.dispose();
      }
    }

  });
})(jQuery);
