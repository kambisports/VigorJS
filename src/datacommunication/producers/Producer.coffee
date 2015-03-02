class Producer

  subscriptionKeyToComponents: {}

  constructor: ->
    do @_addKeysToMap

  addComponent: (subscriptionKey, componentIdentifier) ->
    key = subscriptionKey.key
    registeredComponents = @subscriptionKeyToComponents[key]
    unless registeredComponents
      throw new Error('Unknown subscription key, could not add component!')

    @subscriptionKeyToComponents[key].push componentIdentifier

  produce: (subscriptionKey, data, filterFn = ->) ->

    key = subscriptionKey.key
    @_validateContract(subscriptionKey, data)

    componentsForSubscription = @subscriptionKeyToComponents[key]
    componentsInterestedInChange = _.filter componentsForSubscription, (componentIdentifier) ->
      _.isEmpty(componentIdentifier.options) or filterFn(componentIdentifier.options)

    component.callback(data) for component in componentsInterestedInChange

  subscribe: (subscriptionKey, options) ->
    throw new Error("Subscription handler should be overriden in subclass! Implement for subscription #{subscriptionKey} with options #{options}")

  dispose: ->
    throw new Error("Dispose shuld be overriden in subclass!")

  extend: (obj, mixin) ->
    obj[name] = method for name, method of mixin
    obj

  mixin: (instance, mixin) ->
    @extend instance, mixin

  decorate: (data, decoratorList) ->
    for decorator in decoratorList
      decorator(data)
    return data

  modelsToJSON: (models) ->
    modelsJSON = _.map models, (model) ->
      return model.toJSON()
    return modelsJSON

  _validateContract: (subscriptionKey, dataToProduce) ->
    contract = subscriptionKey.contract

    unless contract
      throw new Error "The #{subscriptionKey.key} does not have any contract specified"
      return false

    unless dataToProduce
      throw new Error "#{@NAME} is calling produce without any data"
      return false

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
      @subscriptionKeyToComponents[subscriptionKey.key] = []

  # Default
  SUBSCRIPTION_KEYS: []
  NAME: 'Producer'

Producer.extend = Vigor.extend
Vigor.Producer = Producer