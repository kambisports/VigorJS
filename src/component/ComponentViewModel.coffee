# ##ComponentViewModel
# This class is intended to be the base class for all view models in a component
#
# A ComponentViewModel handles communication with producers through the
# dataCommunicationManager

class ComponentViewModel

  # @property dataCommunicationManager: DataCommunicationManager
  dataCommunicationManager = Vigor.DataCommunicationManager

  # **constructor** <br/>
  # The constructor generates a unique id for the ViewModel that will be used to
  # handle subscriptions in the dataCommunicationManager
  constructor: ->
    @id = "ComponentViewModel_#{_.uniqueId()}"

  # **dispose** <br/>
  # Remves all subscriptions
  dispose: ->
    do @unsubscribeAll

  # **subscribe** <br/>
  # @param [key]: Object <br/>
  # A Vigor.SubscriptionKey containing a key and contract property<br/>
  # @param [callback]: Function <br/>
  # Callback function that takes care of produced data
  # @param [options]: Object (optional)<br/>
  # Pass any optional data that might be needed by a Producer
  #
  # Adds a subscription on a specific SubscriptionKey to the dataCommunicationManager.
  # Whenever new data is produced the callback will be called with new data as param
  subscribe: (key, callback, options) ->
    dataCommunicationManager.subscribe @id, key, callback, options

  # **unsubscribe** <br/>
  # @param [key]: Object <br/>
  # A Vigor.SubscriptionKey containing a key and contract property<br/>
  #
  # Removes a subscription on specific key
  unsubscribe: (key) ->
    dataCommunicationManager.unsubscribe @id, key

  # **unsubscribeAll** <br/>
  # Removes all subscriptions
  unsubscribeAll: ->
    dataCommunicationManager.unsubscribeAll @id

  # **validateContract** <br/>
  # @param [contract]: Object <br/>
  # The contract specified in the SubscriptionKey used when subscribing for data
  # @param [incommingData]: Object <br/>
  # data supplied through the subscription
  #
  # Compares contract with incomming data and checks values, types, and number
  # of properties, call this method manually from your callback if you want to
  # validate incoming data
  validateContract: (contract, incommingData) ->
    Vigor.helpers.validateContract(contract, incommingData, @id)

ComponentViewModel.extend = Vigor.extend
Vigor.ComponentViewModel = ComponentViewModel