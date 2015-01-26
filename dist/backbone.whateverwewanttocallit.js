(function() {
  (function(root, factory) {
    var Backbone, _;
    if (typeof define === "function" && define.amd) {
      define(['backbone', 'underscore'], function(Backbone, _) {
        return factory(root, Backbone, _);
      });
      console.log('amd');
    } else if (typeof exports === "object") {
      Backbone = require('backbone');
      _ = require('underscore');
      console.log('commonjs');
      module.exports = factory(root, Backbone, _);
    } else {
      console.log('global');
      root.Vigor = factory(root, root.Backbone, root._);
    }
  })(this, function(root, Backbone, _) {
    var PackageBase, Vigor, previousVigor;
    previousVigor = root.Vigor;
    Vigor = Backbone.Vigor = {};
    Vigor.noConflict = function() {
      return root.Vigor = previousVigor;
    };
    PackageBase = (function() {
      function PackageBase() {
        _.extend(this, Backbone.Events);
      }

      PackageBase.prototype.render = function() {
        throw 'PackageBase->render needs to be over-ridden';
      };

      PackageBase.prototype.dispose = function() {
        throw 'PackageBase->dispose needs to be over-ridden';
      };

      return PackageBase;

    })();
    Vigor.PackageBase = PackageBase;
    console.log(Vigor);
    return Vigor;
  });

}).call(this);
