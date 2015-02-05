class ViewModel
  DataCommunicationManager = Vigor.DataCommunicationManager

  id: 'ViewModel'
  subscriptionIds: []

  constructor: ->
    @id = @getUniqueId()

  getUniqueId: ->
    return "#{@id}_#{_.uniqueId()}"

  dispose: ->
    do @unsubscribeAll

  subscribe: (key, callback, options) ->
    return DataCommunicationManager.subscribe @id, key, callback, options

  unsubscribe: (key) ->
    return DataCommunicationManager.unsubscribe @id, key

  unsubscribeAll: ->
    return DataCommunicationManager.unsubscribeAll @id

ViewModel.extend = Vigor.extend
Vigor.ViewModel = ViewModel