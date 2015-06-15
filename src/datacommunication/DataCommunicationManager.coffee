# The DataCommuncationManager is the entry point to communication between view layer and
# data layer. The [ComponentViewModel](ComponentViewModel.html) has a reference to the DataCommunicationManager.
# The DataCommuncationManager can be viewed as the public API betweem the two layers.
#
# The DataCommuncationManager uses the [ProducerManager](ProducerManager.html) to interact with producers
DataCommunicationManager =

  # **registerProducers:** </br>
  # @param [producers]: Array <br/>
  #
  # Registers a one or more [producers] in the data layer
  registerProducers: (producers) ->
    producerManager.registerProducers producers

  # **subscribe:** </br>
  # @param [componentId]: String <br/>
  # @param [subscriptionKey]: Object <br/>
  # @param [callback]: Function <br/>
  # @param [subscriptionOptions]: Object (default empty object) <br/>
  #
  # Registers a component with [componentId] to recieve data changes on given [subscriptionKey] through the component [callback]
  subscribe: (componentId, subscriptionKey, callback, subscriptionOptions = {}) ->
    subscription = new Subscription componentId, callback, subscriptionOptions
    producerManager.subscribeComponentToKey subscriptionKey, subscription

  # **unsubscribe:** </br>
  # @param [componentId]: String <br/>
  # @param [subscriptionKey]: Object <br/>
  #
  # Unsubscribes a component from recieving data
  unsubscribe: (componentId, subscriptionKey) ->
    producerManager.unsubscribeComponentFromKey subscriptionKey, componentId

  # **unsubscribeAll:** </br>
  # @param [componentId]: String <br/>
  #
  # Removes all subscriptions for the given component id
  unsubscribeAll: (componentId) ->
    producerManager.unsubscribeComponent componentId

# Expose the DataCommuncationManager on Vigor
Vigor.DataCommunicationManager = DataCommunicationManager
