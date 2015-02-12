var app = app || {};

(function ($) {
  'use strict';

  app.HelloWorld = Vigor.PackageBase.extend({
    $el: undefined,
    _helloWorldViewModel: undefined,
    _helloWorldView: undefined,

    constructor: function (options) {
      var viewModelId = 'dummy';
      Vigor.PackageBase.prototype.constructor.call(this, options);
      this._helloWorldViewModel = new app.HelloWorldViewModel(viewModelId);
      this._helloWorldView = new app.HelloWorldView({viewModel: this._helloWorldViewModel});
    },

    render: function () {
      this.$el = this._helloWorldView.render().$el;
      return this;
    },

    dispose: function () {
      this._helloWorldView.dispose();
      this._helloWorldViewModel.dispose();
      this._helloWorldView = undefined;
      this._helloWorldViewModel = undefined;
    }

  });
})(jQuery);
