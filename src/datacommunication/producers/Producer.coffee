class Producer

  _isSubscribedToRepositories: false
  subscriptionKeyToComponents: {}

  constructor: ->
    do @_addKeysToMap

  getInstance: ->
    unless @instance?
      @instance = new @constructor()
    @instance

  addComponent: (subscriptionKey, subscription) ->
    key = subscriptionKey.key
    registeredComponents = @subscriptionKeyToComponents[key]

    unless registeredComponents
      throw new Error("Unknown subscription key: #{key}, could not add component!")

    existingSubscription = registeredComponents[subscription.id]
    if existingSubscription?
      throw "Component #{subscription.id} is already subscribed to the key #{subscriptionKey.key}"

    registeredComponents[subscription.id] = subscription
    @subscribe subscriptionKey, subscription.options

    unless @_isSubscribedToRepositories
      @subscribeToRepositories()
      @_isSubscribedToRepositories = true

  removeComponent: (subscriptionKey, componentId) ->
    key = subscriptionKey.key
    # handle call with only componentId; remove component for all keys
    unless componentId?
      componentId = subscriptionKey
      _.each @SUBSCRIPTION_KEYS, (subscriptionKey) ->
        @removeComponent subscriptionKey, componentId
      , @
      return

    registeredComponents = @subscriptionKeyToComponents[key]

    subscription = registeredComponents[componentId]

    if subscription?
      @unsubscribe subscriptionKey, subscription.options
      delete registeredComponents[subscription.id]

      if @shouldUnsubscribeFromRepositories()
        @unsubscribeFromRepositories()
        @_isSubscribedToRepositories = false

  produce: (subscriptionKey, data, filterFn = ->) ->
    key = subscriptionKey.key
    type = Object.prototype.toString.call(@).slice(8, -1)
    @_validateContract subscriptionKey, data, type

    componentsForSubscription = @subscriptionKeyToComponents[key]
    componentsInterestedInChange = _.filter componentsForSubscription, (componentIdentifier) ->
      _.isEmpty(componentIdentifier.options) or filterFn(componentIdentifier.options)

    component.callback(data) for component in componentsInterestedInChange

  subscribe: (subscriptionKey, options) ->
    throw new Error("Subscription handler should be overriden in subclass! Implement for subscription #{subscriptionKey} with options #{options}")

  unsubscribe: (subscriptionKey, options) ->

  subscribeToRepositories: ->
    throw 'subscribeToRepositories should be overridden in subclass!'

  unsubscribeFromRepositories: ->
    throw 'unsubscribeFromRepositories should be overridden in subclass!'

  shouldUnsubscribeFromRepositories: ->
    # for..in finds out whether there are any keys
    # faster than checking whether the length of the keys is 0
    for key, components of @subscriptionKeyToComponents
      for component of components
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

  _validateContract: (subscriptionKey, dataToProduce) ->
    contract = subscriptionKey.contract
    unless contract
      throw new Error "The subscriptionKey #{subscriptionKey.key} doesn't have a contract specified"

    return Vigor.helpers.validateContract(contract, dataToProduce, @, 'producing')

  # add valid subscription keys to map (keys listed in subclass)
  _addKeysToMap: ->
    for subscriptionKey in @SUBSCRIPTION_KEYS
      @subscriptionKeyToComponents[subscriptionKey.key] = {}

  # Default
  SUBSCRIPTION_KEYS: []

Producer.extend = Vigor.extend
Vigor.Producer = Producer