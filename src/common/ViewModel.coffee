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
    unless contract
      throw new Error "The #{@id} does not have any contract specified"
      return false

    unless incommingData
      throw new Error "#{@id}'s callback for subscribe is called but it does not recieve any data"
      return false

    if _.isArray(contract) and _.isArray(incommingData) is false
      console.warn "#{@id} is supposed to recieve an array but is recieving #{typeof incommingData}"

    if _.isObject(contract) and _.isArray(contract) is false and _.isArray(incommingData)
      console.warn "#{@id} is supposed to recieve an object but is recieving an array"

    if _.isObject(contract) and _.isArray(contract) is false
      contractKeyCount = _.keys(contract).length
      dataKeyCount = _.keys(incommingData).length

      #TODO: should below warnings be errors instead?
      if dataKeyCount > contractKeyCount
        console.warn "#{@id} is recieving more data then what is specified in the contract", contract, incommingData
      else if dataKeyCount < contractKeyCount
        console.warn "#{@id} is recieving less data then what is specified in the contract", contract, incommingData

    for key, val of contract
      if val?
        unless typeof incommingData[key] is typeof val
          console.warn "#{@id} is recieving data of the wrong type according to the contract, #{key}, expects #{typeof val} but gets #{typeof incommingData[key]}"

      unless key of incommingData
        console.warn "#{@id} recieving data but is missing the key: #{key}"

    return true

ViewModel.extend = Vigor.extend
Vigor.ViewModel = ViewModel