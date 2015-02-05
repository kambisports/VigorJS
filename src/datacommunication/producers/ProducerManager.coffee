class ProducerManager

  producerMapper: new Vigor.ProducerMapper()
  instansiatedProducers: {}

  addProducersToMap: (producers) ->
    if _.isArray producers
      for producerClass in producers
        @producerMapper.addProducerClass producerClass
    else
      @producerMapper.addProducerClass producers

  removeProducersFromMap: (producers) ->
    if _.isArray producers
      for producerClass in producers
        @producerMapper.removeProducerClass producerClass
    else
      @producerMapper.removeProducerClass producers

  removeAllProducersFromMap: ->
    do @producerMapper.removeAllProducers

  getProducer: (subscriptionKey) ->
    producerClass = @producerMapper.findProducerClassForSubscription subscriptionKey
    @_instansiateProducer producerClass

  removeProducer: (subscriptionKey) ->
    producerClass = @producerMapper.findProducerClassForSubscription subscriptionKey

    producer = @instansiatedProducers[producerClass.prototype.NAME]
    if producer
      do producer.dispose
      delete @instansiatedProducers[producerClass.prototype.NAME]

  addComponentToProducer: (subscriptionKey, componentIdentifier) ->
    producer = @getProducer subscriptionKey

    # add sub key so producer know what components to call produce for!
    producer.addComponent subscriptionKey, componentIdentifier

  subscribe: (subscriptionKey, options) ->
    producerClass = @producerMapper.findProducerClassForSubscription subscriptionKey
    producer = @_instansiateProducer producerClass

    # synchronous call
    producer.subscribe subscriptionKey, options

  _instansiateProducer: (producerClass) ->
    if not @instansiatedProducers[producerClass.prototype.NAME]
      producer = new producerClass()
      @instansiatedProducers[producerClass.prototype.NAME] = producer

    @instansiatedProducers[producerClass.prototype.NAME]

Vigor.ProducerManager = ProducerManager