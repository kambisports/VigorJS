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

  # **subscribe:** </br>
  # @param [componentId]: String <br/>
  # @param [subscriptionKey]: Object <br/>
  # @param [callback]: Function <br/>
  # @param [subscriptionOptions]: Object (default empty object) <br/>
  #
  # Registers a component with [componentId] to recieve data changes on given [subscriptionKey] through the component [callback]
  subscribe: (componentId, subscriptionKey, callback, subscriptionOptions = {}) ->
    subscription = new Subscription componentId, callback, subscriptionOptions
    producer = @producerForKey subscriptionKey
    producer.addComponent subscription

  # **unsubscribe:** </br>
  # @param [componentId]: String <br/>
  # @param [subscriptionKey]: String <br/>
  #
  # Unsubscribes a component with [componentId] from the producer for the given [subscriptionKey]
  unsubscribe: (componentId, subscriptionKey) ->
    producer = @producerForKey subscriptionKey
    producer.removeComponent componentId

  # **unsubscribeAll:** </br>
  # @param [componentId]: String <br/>
  #
  # Unsubscribes a component with [componentId] from any producer that might have it in its subscription
  unsubscribeAll: (componentId) ->
    producerMapper.producers.forEach (producer) ->
      producer::getInstance().removeComponent componentId

Vigor.ProducerManager = producerManager
