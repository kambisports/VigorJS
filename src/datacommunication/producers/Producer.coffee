class Producer
  
  # the production key should be overridden in the subclass
  PRODUCTION_KEY: undefined

  _isSubscribedToRepositories: false

  constructor: ->
    @registeredComponents = {}

  getInstance: ->
    unless @instance?
      @instance = new @constructor()
    @instance

  addComponent: (subscription) ->
    existingSubscription = @registeredComponents[subscription.id]
    unless existingSubscription?
      @registeredComponents[subscription.id] = subscription
      @subscribe subscription.options

      unless @_isSubscribedToRepositories
        @subscribeToRepositories()
        @_isSubscribedToRepositories = true

  removeComponent: (componentId) ->
    subscription = @registeredComponents[componentId]

    if subscription?
      @unsubscribe subscription.options
      delete @registeredComponents[subscription.id]

      if @shouldUnsubscribeFromRepositories()
        @unsubscribeFromRepositories()
        @_isSubscribedToRepositories = false

  produce: (data, filterFn = ->) ->
    type = Object.prototype.toString.call(@).slice(8, -1)
    @_validateContract data, type

    componentsInterestedInChange = _.filter @registeredComponents, (componentIdentifier) ->
      _.isEmpty(componentIdentifier.options) or filterFn(componentIdentifier.options)

    component.callback(data) for component in componentsInterestedInChange

  subscribe: (options) ->
    throw new Error("Subscription handler should be overriden in subclass! Implement for subscription #{subscriptionKey} with options #{options}")

  unsubscribe: (options) ->

  subscribeToRepositories: ->
    throw 'subscribeToRepositories should be overridden in subclass!'

  unsubscribeFromRepositories: ->
    throw 'unsubscribeFromRepositories should be overridden in subclass!'

  shouldUnsubscribeFromRepositories: ->
    # for..in finds out whether there are any keys
    # faster than checking whether the length of the keys is 0
    for component of @registeredComponents
      return false

    return true


  extend: (obj, mixin) ->
    obj[name] = method for name, method of mixin
    return obj

  mixin: (instance, mixin) ->
    @extend instance, mixin

  decorate: (data, decoratorList) ->
    for decorator in decoratorList
      decorator(data)
    return data

  modelToJSON: (model) ->
    return model.toJSON()

  modelsToJSON: (models) ->
    _.map models, @modelToJSON

  _validateContract: (dataToProduce) ->
    contract = @PRODUCTION_KEY.contract
    unless contract
      throw new Error "The subscriptionKey #{subscriptionKey.key} doesn't have a contract specified"

    return Vigor.helpers.validateContract(contract, dataToProduce, @, 'producing')

Producer.extend = Vigor.extend
Vigor.Producer = Producer