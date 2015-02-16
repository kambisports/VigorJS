class Producer

  subscriptionKeyToComponents: {}

  constructor: ->
    do @_addKeysToMap

  addComponent: (subscriptionKey, componentIdentifier) ->
    registeredComponents = @subscriptionKeyToComponents[subscriptionKey]
    unless registeredComponents
      throw new Error('Unknown subscription key, could not add component!')

    @subscriptionKeyToComponents[subscriptionKey].push componentIdentifier

  produce: (subscriptionKey, data, filterFn) ->
    componentsForSubscription = @subscriptionKeyToComponents[subscriptionKey]
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

  # add valid subscription keys to map (keys listed in subclass)
  _addKeysToMap: ->
    for key in @SUBSCRIPTION_KEYS
      @subscriptionKeyToComponents[key] = []

  # Default
  SUBSCRIPTION_KEYS: []
  NAME: 'Producer'

Producer.extend = Vigor.extend
Vigor.Producer = Producer