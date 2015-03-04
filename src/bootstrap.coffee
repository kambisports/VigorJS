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

  Vigor.extend = Backbone.Model.extend

  # COMMON
  #= include ./common/EventBus.coffee
  #= include ./common/PackageBase.coffee

  # DATACOMMUNICATION/PRODUCERS
  #= include ./datacommunication/producers/Producer.coffee
  #= include ./datacommunication/producers/ProducerMapper.coffee
  #= include ./datacommunication/producers/ProducerManager.coffee

  # DATACOMMUNICATION/APISERVICES
  #= include ./datacommunication/apiservices/APIService.coffee

  # DATACOMMUNICATION
  #= include ./datacommunication/SubscriptionKeys.coffee
  #= include ./datacommunication/EventKeys.coffee
  #= include ./datacommunication/ComponentIdentifier.coffee
  #= include ./datacommunication/DataCommunicationManager.coffee

  #= include ./common/ComponentView.coffee
  #= include ./common/ViewModel.coffee

  # REPOSITORIES
  #= include ./datacommunication/repositories/Repository.coffee
  #= include ./datacommunication/repositories/ServiceRepository.coffee

  return Vigor
