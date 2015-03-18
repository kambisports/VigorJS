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
    @_validateContract(subscriptionKey, data)

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
      throw new Error "The #{subscriptionKey.key} does not have any contract specified"
      return false

    unless dataToProduce
      throw new Error "#{@NAME} is calling produce without any data"
      return false

    if _.isArray(contract) and _.isArray(dataToProduce) is false
      console.warn "#{@NAME} is supposed to produce an array but is producing #{typeof dataToProduce}"

    if _.isObject(contract) and _.isArray(contract) is false
      contractKeyCount = _.keys(contract).length
      dataKeyCount = _.keys(dataToProduce).length

      #TODO: should below warnings be errors instead?
      if dataKeyCount > contractKeyCount
        console.warn "#{@NAME} is calling produce with more data then what is specified in the contract"
      else if dataKeyCount < contractKeyCount
        console.warn "#{@NAME} is calling produce with less data then what is specified in the contract"

    for key, val of contract
      if val?
        unless typeof dataToProduce[key] is typeof val
          console.warn "#{@NAME} is producing data of the wrong type according to the contract, #{key}, expects #{typeof val} but gets #{typeof dataToProduce[key]}"

      unless key of dataToProduce
        console.warn "#{@NAME} producing data but is missing the key: #{key}"

    return true

  # add valid subscription keys to map (keys listed in subclass)
  _addKeysToMap: ->
    for subscriptionKey in @SUBSCRIPTION_KEYS
      @subscriptionKeyToComponents[subscriptionKey.key] = {}

  # Default
  SUBSCRIPTION_KEYS: []

Producer.extend = Vigor.extend
Vigor.Producer = Producer