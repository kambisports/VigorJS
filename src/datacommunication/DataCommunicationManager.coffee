class DataCommunicationManager

  ProducerManager = Vigor.ProducerManager
  # ApiServices = require 'datacommunication/apiservices'
  ComponentIdentifier = Vigor.ComponentIdentifier

  subscriptionsWithComponentIdentifiers: undefined
  subscriptionsWithProducers: undefined

  producerManager: undefined
  apiServices: undefined

  constructor: ->
    @subscriptionsWithComponentIdentifiers = {}
    @subscriptionsWithProducers = {}

    @producerManager = new ProducerManager()

    # Only used to create singletons of services in application
    # @apiServices = new ApiServices()

  registerProducers: (producers) ->
    @producerManager.addProducersToMap producers

  unregisterProducers: (producers) ->
    @producerManager.removeProducersFromMap producers

  unregisterAllProducers: ->
    do @producerManager.removeAllProducersFromMap

  # Public methods
  subscribe: (componentId, subscriptionKey, subscriptionCb, subscriptionOptions = {}) ->
    componentIdentifier = new ComponentIdentifier(componentId, subscriptionCb, subscriptionOptions)
    keys = _.keys @subscriptionsWithComponentIdentifiers

    if _.indexOf(keys, subscriptionKey.key) is -1
      @_createSubscription subscriptionKey

    # we have the subscription key already, add component id to list of components for that subscription
    @_addComponentToSubscription subscriptionKey, componentIdentifier
    @producerManager.subscribe subscriptionKey, subscriptionOptions


  unsubscribe: (componentId, subscriptionKey) ->
    # remove component for subscription key, if all components have been removed, remove subscription as well
    @_removeComponentFromSubscription subscriptionKey, componentId


  unsubscribeAll: (componentId) ->
    # clear all subscriptions for given component
    keys = _.keys @subscriptionsWithComponentIdentifiers
    len = keys.length

    while len--
      @_removeComponentFromSubscription keys[len], componentId


  # Private methods
  _createSubscription: (subscriptionKey) ->
    key = subscriptionKey.key
    @subscriptionsWithComponentIdentifiers[key] = []
    producer = @producerManager.getProducer subscriptionKey
    @subscriptionsWithProducers[key] = producer


  _removeSubscription: (subscriptionKey) ->
    key = subscriptionKey.key
    delete @subscriptionsWithComponentIdentifiers[key]
    delete @subscriptionsWithProducers[key]
    @producerManager.removeProducer subscriptionKey


  _addComponentToSubscription: (subscriptionKey, componentIdentifier) ->
    key = subscriptionKey.key
    subscriptionComponents = @subscriptionsWithComponentIdentifiers[key]

    existingComponent = _.find subscriptionComponents, (component) ->
      component.id is componentIdentifier.id

    unless existingComponent
      subscriptionComponents.push componentIdentifier
      @producerManager.addComponentToProducer subscriptionKey, componentIdentifier


  _removeComponentFromSubscription: (subscriptionKey, componentId) ->
    key = subscriptionKey.key
    components = @subscriptionsWithComponentIdentifiers[key]

    componentIndex = -1
    for component, index in components
      if component.id is componentId then componentIndex = index

    if componentIndex > -1 then components.splice componentIndex, 1

    # if subscription no long contains any components -> remove the subscription as well
    unless @_isSubscriptionValid(subscriptionKey) then @_removeSubscription(subscriptionKey)


  # Key is present in map and contains array of at least one component mapped for subscription
  _isSubscriptionValid: (subscriptionKey) ->
    key = subscriptionKey.key
    componentIdentifiers = @subscriptionsWithComponentIdentifiers[key]
    if _.isEmpty(componentIdentifiers) then false else true


  # Unit testing of singleton
  makeTestInstance: ->
    new DataCommunicationManager()

Vigor.DataCommunicationManager = new DataCommunicationManager()

