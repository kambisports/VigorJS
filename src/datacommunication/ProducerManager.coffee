#  ## ProducerManager
# The ProducerManager utilizies the [ProducerMapper](ProducerMapper.html) to (un)register components on subscriptions.
#
producerManager =

  # **registerProducers:** </br>
  # @param [producers]: Array <br/>
  #
  # Registers a one or more producers in mapper
  registerProducers: (producers) ->
    producers.forEach (producer) ->
      producerMapper.register producer

  # **producerForKey:** </br>
  # @param [subscriptionKey]: String <br/>
  # @returns [producer]: Producer </br>
  #
  # Retrieves a registered producer for the given subscription
  producerForKey: (subscriptionKey) ->
    producer = producerMapper.producerForKey subscriptionKey

  # **subscribeComponentToKey:** </br>
  # @param [subscriptionKey]: String <br/>
  # @param [subscription]: Object <br/>
  #
  # Adds a component to the producer for the given [subscriptionKey]
  subscribeComponentToKey: (subscriptionKey, subscription) ->
    producer = @producerForKey subscriptionKey
    producer.addComponent subscription

  # **unsubscribeComponentFromKey:** </br>
  # @param [subscriptionKey]: String <br/>
  # @param [componentId]: String <br/>
  #
  # Unsubscribes a component with [componentId] from the producer for the given [subscriptionKey]
  unsubscribeComponentFromKey: (subscriptionKey, componentId) ->
    producer = @producerForKey subscriptionKey
    producer.removeComponent componentId

  # **unsubscribeComponent:** </br>
  # @param [componentId]: String <br/>
  #
  # Unsubscribes a component with [componentId] from any producer that might have it in its subscription
  unsubscribeComponent: (componentId) ->
    producerMapper.producers.forEach (producer) ->
      producer::getInstance().removeComponent componentId

### start-test-block ###
# this will be removed in distribution build since the manager should be private
Vigor.ProducerManager = producerManager
### end-test-block ###
