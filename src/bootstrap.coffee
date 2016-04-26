((root, factory) ->
  if typeof define is "function" and define.amd

    # AMD. Register as an anonymous module.
    define ['backbone', 'lodash', 'jquery'], (Backbone, _, $) ->
        return factory(root, Backbone, _, $)

  else if typeof exports is "object"
    Backbone = require 'backbone'
    _ = require 'underscore'
    $ = require 'jquery'

    # Node. Does not work with strict CommonJS, but
    # only CommonJS-like environments that support module.exports,
    # like Node.
    module.exports = factory(root, Backbone, _, $)
  else

    # Browser globals (root is window)
    root.Vigor = factory(root, root.Backbone, root._, root.$)
  return

) @, (root, Backbone, _, $) ->

  previousVigor = root.Vigor
  Vigor = Backbone.Vigor = {}
  Vigor.helpers = {}
  Vigor.settings = {}

  Vigor.noConflict = ->
    root.Vigor = previousVigor

  Vigor.extend = Backbone.Model.extend

  #= include ./setup.coffee

  # HELPERS
  #= include ./helpers/validateContract.coffee

  # COMMON
  #= include ./common/EventBus.coffee
  #= include ./common/SubscriptionKeys.coffee
  #= include ./common/EventKeys.coffee

  # DATACOMMUNICATION
  #= include ./datacommunication/Subscription.coffee
  #= include ./datacommunication/ProducerMapper.coffee
  #= include ./datacommunication/ProducerManager.coffee

  # DATACOMMUNICATION/PRODUCERS
  #= include ./datacommunication/producers/Producer.coffee
  #= include ./datacommunication/producers/IdProducer.coffee

  # DATACOMMUNICATION/APISERVICES
  #= include ./datacommunication/apiservices/APIService.coffee

  # COMPONENTS
  #= include ./component/ComponentBase.coffee
  #= include ./component/ComponentView.coffee
  #= include ./component/ComponentViewModel.coffee

  # REPOSITORIES
  #= include ./datacommunication/repositories/Repository.coffee
  #= include ./datacommunication/repositories/ServiceRepository.coffee

  return Vigor
