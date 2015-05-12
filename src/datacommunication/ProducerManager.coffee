producerManager =

  registerProducers: (producers) ->
    producers.forEach (producer) ->
      producerMapper.register producer

  producerForKey: (subscriptionKey) ->
    producer = producerMapper.producerForKey subscriptionKey

  subscribeComponentToKey: (subscriptionKey, subscription) ->
    producer = @producerForKey subscriptionKey
    producer.addComponent subscription

  unsubscribeComponentFromKey: (subscriptionKey, componentId) ->
    producer = @producerForKey subscriptionKey
    producer.removeComponent componentId

  unsubscribeComponent: (componentId) ->
    producerMapper.producers.forEach (producer) ->
      producer::getInstance().removeComponent componentId

### start-test-block ###
# this will be removed in distribution build
Vigor.ProducerManager = producerManager
### end-test-block ###
