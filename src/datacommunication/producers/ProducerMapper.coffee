do ->

  producers = []
  subscriptionKeyToProducerMap = {}

  ProducerMapper =
    findProducerClassForSubscription: (subscriptionKey) ->
      key = subscriptionKey.key
      producerClass = subscriptionKeyToProducerMap[key]
      throw "There are no producers registered - register producers through the DataCommunicationManager" unless producers.length > 0
      throw "No producer found for subscription #{key}!" unless producerClass
      return producerClass

    addProducerClass: (producerClass) ->
      if producers.indexOf(producerClass) is -1
        producers.push producerClass
        do _buildMap
      return @

    removeProducerClass: (producerClass) ->
      index = producers.indexOf(producerClass)
      if index isnt -1
        producers.splice index, 1

        producerClass.prototype.SUBSCRIPTION_KEYS.forEach (subscriptionKey) =>
          key = subscriptionKey.key
          delete subscriptionKeyToProducerMap[key]

        do _buildMap
      return @

    getAllProducers: ->
      return producers

    removeAllProducers: ->
      producers = []
      subscriptionKeyToProducerMap = {}

  _buildMap = ->
    producers.forEach (producer) =>
      producer.prototype.SUBSCRIPTION_KEYS.forEach (subscriptionKey) =>
        key = subscriptionKey.key
        subscriptionKeyToProducerMap[key] = producer

  Vigor.ProducerMapper = ProducerMapper
