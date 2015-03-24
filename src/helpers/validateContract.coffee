validateContract = (contract, dataToCompare, comparatorId, verb = 'recieving') ->
  unless Vigor.settings.validateContract then return
  unless contract
    throw new Error "The #{comparatorId} does not have any contract specified"
    return false

  unless dataToCompare
    throw new Error "#{comparatorId} is trying to validate the contract but does not recieve any data to compare against the contract"
    return false

  if _.isArray(contract) and _.isArray(dataToCompare) is false
    throw new Error "#{comparatorId}'s compared data is supposed to be an array but is a #{typeof dataToCompare}"
    return false

  if _.isObject(contract) and _.isArray(contract) is false and _.isArray(dataToCompare)
    throw new Error "#{comparatorId}'s compared data is supposed to be an object but is an array"
    return false

  if _.isObject(contract) and _.isArray(contract) is false
    contractKeyCount = _.keys(contract).length
    dataKeyCount = _.keys(dataToCompare).length

    #TODO: should below warnings be errors instead?
    if dataKeyCount > contractKeyCount
      throw new Error "#{comparatorId} is #{verb} more data then what is specified in the contract", contract,dataToCompare
      return false
    else if dataKeyCount < contractKeyCount
      throw new Error "#{comparatorId} is #{verb} less data then what is specified in the contract", contract,dataToCompare
      return false

  for key, val of contract
    if val?
      unless typeof dataToCompare[key] is typeof val
        throw new Error "#{comparatorId} is #{verb} data of the wrong type according to the contract, #{key}, expects #{typeof val} but gets #{typeof dataToCompare[key]}"
        return false

    unless key of dataToCompare
      throw new Error "#{comparatorId} has data but is missing the key: #{key}"
      return false

  return true

Vigor.helpers.validateContract = validateContract