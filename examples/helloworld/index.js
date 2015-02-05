var app = app || {};

(function ($) {
  'use strict';

  app.HelloWorld = Vigor.PackageBase.extend({
    $el: undefined,
    _helloWorldViewModel: undefined,
    _helloWorldView: undefined,

    constructor: function () {
      Vigor.ComponentView.prototype.constructor.call(this, options);
      this._helloWorldViewModel = new app.HelloWorldViewModel();
      this._helloWorldView = new app.HelloWorldView({viewModel: this._helloWorldViewModel});
    },

    render: function () {
      this.$el = this._helloWorldView.render().$el;
      return this;
    },

    dispose: function () {

    }

  });
})(jQuery);
