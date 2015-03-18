do ->

  Subscription = Vigor.ComponentIdentifier
  producerManager = Vigor.ProducerManager

  DataCommunicationManager =

    registerProducers: (producers) ->
      producerManager.registerProducers producers

    subscribe: (componentId, subscriptionKey, callback, subscriptionOptions = {}) ->
      subscription = new Subscription componentId, callback, subscriptionOptions
      producerManager.subscribeComponentToKey subscriptionKey, subscription

    unsubscribe: (componentId, subscriptionKey) ->
      producerManager.unsubscribeComponentFromKey subscriptionKey, componentId

    unsubscribeAll: (componentId) ->
      producerManager.unsubscribeComponent componentId

  Vigor.DataCommunicationManager = DataCommunicationManager
