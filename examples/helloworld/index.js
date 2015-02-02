var app = app || {};

(function ($) {
  'use strict';

  app.HelloWorld = Vigor.PackageBase.extend({
    $el: undefined,
    _helloWorldViewModel: undefined,
    _helloWorldView: undefined,

    constructor: function () {
      this._helloWorldViewModel = new app.HelloWorldViewModel();
      this._helloWorldView = new app.HelloWorldView({viewModel: this._helloWorldViewModel});
      console.log('HelloWorld ', this._helloWorldView);
    },

    render: function () {
      this.$el = this._helloWorldView.render().$el;
      return this;
    },

    dispose: function () {

    }

  });
})(jQuery);
