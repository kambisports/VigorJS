producers = []
producersByKey = {}

NO_PRODUCERS_ERROR = "There are no producers registered - register producers through the DataCommunicationManager"
NO_PRODUCER_FOUND_ERROR = (key) ->
  "No producer found for subscription #{key}!"
KEY_ALREADY_REGISTERED = (key) ->
  "A producer for the key #{key} is already registered"

producerMapper =

  producers: producers

  producerClassForKey: (subscriptionKey) ->
    key = subscriptionKey.key
    if producers.length is 0
      throw NO_PRODUCERS_ERROR

    producerClass = producersByKey[key]

    unless producerClass
      throw NO_PRODUCER_FOUND_ERROR key

    return producerClass

  producerForKey: (subscriptionKey) ->
    producerClass = @producerClassForKey subscriptionKey
    producerClass::getInstance()

  register: (producerClass) ->
    if (producers.indexOf producerClass) is -1
      producers.push producerClass

      subscriptionKey = producerClass::PRODUCTION_KEY
      key = subscriptionKey.key

      if producersByKey[key]?
        throw KEY_ALREADY_REGISTERED key

      producersByKey[key] = producerClass

  reset: ->
    producers.length = 0
    producersByKey = {}

### start-test-block ###
# this will be removed in distribution build
Vigor.ProducerMapper = producerMapper
### end-test-block ###
