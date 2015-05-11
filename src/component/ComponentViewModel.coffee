class ComponentViewModel

  dataCommunicationManager = Vigor.DataCommunicationManager

  constructor: ->
    @id = "ComponentViewModel_#{_.uniqueId()}"

  dispose: ->
    do @unsubscribeAll

  subscribe: (key, callback, options) ->
    return dataCommunicationManager.subscribe @id, key, callback, options

  unsubscribe: (key) ->
    return dataCommunicationManager.unsubscribe @id, key

  unsubscribeAll: ->
    return dataCommunicationManager.unsubscribeAll @id

  validateContract: (contract, incommingData) ->
    return Vigor.helpers.validateContract(contract, incommingData, @id)

ComponentViewModel.extend = Vigor.extend
Vigor.ComponentViewModel = ComponentViewModel