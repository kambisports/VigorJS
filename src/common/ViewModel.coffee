class ViewModel

  dataCommunicationManager = Vigor.DataCommunicationManager

  constructor: ->
    @id = "ViewModel_#{_.uniqueId()}"

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

ViewModel.extend = Vigor.extend
Vigor.ViewModel = ViewModel