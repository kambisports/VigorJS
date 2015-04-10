do ->

  producers = []
  producersByKey = {}

  NO_PRODUCERS_ERROR = "There are no producers registered - register producers through the DataCommunicationManager"
  NO_PRODUCER_FOUND_ERROR = (key) ->
    "No producer found for subscription #{key}!"

  ProducerMapper =

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
        producersByKey[key] = producerClass

    reset: ->
      producers = []
      producersByKey = {}

  Vigor.ProducerMapper = ProducerMapper
