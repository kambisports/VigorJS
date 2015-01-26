((root, factory) ->
  if typeof define is "function" and define.amd

    # AMD. Register as an anonymous module.
    define ['backbone', 'underscore'], (Backbone, _) ->
        return factory(root, Backbone, _)
    console.log 'amd'

  else if typeof exports is "object"
    Backbone = require 'backbone'
    _ = require 'underscore'
    # Node. Does not work with strict CommonJS, but
    # only CommonJS-like environments that support module.exports,
    # like Node.
    console.log 'commonjs'
    module.exports = factory(root, Backbone, _)
  else

    console.log 'global'
    # Browser globals (root is window)
    root.Vigor = factory(root, root.Backbone, root._)
  return

) @, (root, Backbone, _) ->

  previousVigor = root.Vigor
  Vigor = Backbone.Vigor = {}

  Vigor.noConflict = ->
    root.Vigor = previousVigor

  # Just return a value to define the module export.
  # This example returns an object, but the module
  # can return a function as the exported value.
  # {}

  #= include ./common/PackageBase.coffee
  console.log Vigor
  return Vigor
