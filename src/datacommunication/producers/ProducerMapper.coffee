class ProducerMapper

  producers: []
  subscriptionKeyToProducerMap: {}

  constructor: ->
    do @_buildMap

  findProducerClassForSubscription: (subscriptionKey) ->
    producerClass = @subscriptionKeyToProducerMap[subscriptionKey]
    throw "There are no producers registered - register producers through the DataCommunicationManager" unless @producers.length > 0
    throw "No producer found for subscription #{subscriptionKey}!" unless producerClass
    return producerClass

  addProducerClass: (producerClass) ->
    if @producers.indexOf(producerClass) is -1
      @producers.push producerClass
      do @_buildMap
    return @

  removeProducerClass: (producerClass) ->
    index = @producers.indexOf(producerClass)
    if index isnt -1
      @producers.splice index, 1

      producerClass.prototype.SUBSCRIPTION_KEYS.forEach (subscriptionKey) =>
        delete @subscriptionKeyToProducerMap[subscriptionKey]

      do @_buildMap
    return @

  removeAllProducers: ->
    @producers = []
    @subscriptionKeyToProducerMap = {}

  _buildMap: ->
    # console.log '@producers: ', @producers
    @producers.forEach (producer) =>
      debugger

      producer.prototype.SUBSCRIPTION_KEYS.forEach (subscriptionKey) =>
        @subscriptionKeyToProducerMap[subscriptionKey] = producer

Vigor.ProducerMapper = ProducerMapper