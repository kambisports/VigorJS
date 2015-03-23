do ->

  producerMapper = Vigor.ProducerMapper

  ProducerManager =

    registerProducers: (producers) ->
      producers.forEach (producer) =>
        producerMapper.register producer

    producerForKey: (subscriptionKey) ->
      producer = producerMapper.producerForKey subscriptionKey

    subscribeComponentToKey: (subscriptionKey, subscription) ->
      producer = @producerForKey subscriptionKey
      producer.addComponent subscriptionKey, subscription

    unsubscribeComponentFromKey: (subscriptionKey, componentId) ->
      producer = @producerForKey subscriptionKey
      producer.removeComponent subscriptionKey, componentId

    unsubscribeComponent: (componentId) ->
      producerMapper.producers.forEach (producer) ->
        producer::getInstance().removeComponent componentId

  Vigor.ProducerManager = ProducerManager
