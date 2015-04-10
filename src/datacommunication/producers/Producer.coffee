class Producer
  
  # the production key should be overridden in the subclass
  PRODUCTION_KEY: undefined
  repositories: []

  _isSubscribedToRepositories: false


  constructor: ->
    @registeredComponents = {}
    @produceData = _.throttle @produceDataSync, 100


  getInstance: ->
    unless @instance?
      @instance = new @constructor()
    @instance


  addComponent: (subscription) ->
    existingSubscription = @registeredComponents[subscription.id]
    unless existingSubscription?
      @registeredComponents[subscription.id] = subscription
      @subscribe subscription.options

      unless @_isSubscribedToRepositories
        @subscribeToRepositories()
        @_isSubscribedToRepositories = true


  removeComponent: (componentId) ->
    subscription = @registeredComponents[componentId]

    if subscription?
      @unsubscribe subscription.options
      delete @registeredComponents[subscription.id]

      if @_shouldUnsubscribeFromRepositories()
        @unsubscribeFromRepositories()
        @_isSubscribedToRepositories = false


  subscribeToRepositories: ->
    for repository in @repositories
      if repository instanceof Vigor.Repository
        @subscribeToRepository repository
      else if repository.repository instanceof Vigor.Repository and typeof repository.callback is 'string'
        @subscribeToRepository repository.repository, @[repository.callback]
      else
        throw 'unexpected format of producer repositories definition'


  unsubscribeFromRepositories: ->
    for repository in @repositories
      if repository instanceof Vigor.Repository
        @unsubscribeFromRepository repository
      else if repository.repository instanceof Vigor.Repository and typeof repository.callback is 'string'
        @unsubscribeFromRepository repository.repository


  subscribeToRepository: (repository, callback) ->
    callback = callback or (diff) =>
      @onDiffInRepository repository, diff

    @listenTo repository, Vigor.Repository::REPOSITORY_DIFF, callback


  unsubscribeFromRepository: (repository) ->
    @stopListening repository, Vigor.Repository::REPOSITORY_DIFF


  subscribe: (options) ->
    @produceDataSync()


  onDiffInRepository: =>
    @produceData()


  produceDataSync: ->
    @produce @currentData()


  produce: (data) ->
    @_validateContract data
    (component.callback data) for component in @getProduceTargets()


  getProduceTargets: ->
    # TODO: move this logic, or something like it, to IdProducer
    # _.filter @registeredComponents, (componentIdentifier) ->
    #   _.isEmpty(componentIdentifier.options) or filterFn(componentIdentifier.options)
    _.filter @registeredComponents

  currentData: ->
    # default implementation is a noop

  unsubscribe: (options) ->
    # default implementation is a noop


  _shouldUnsubscribeFromRepositories: ->
    # for..in finds out whether there are any keys
    # faster than checking whether the length of the keys is 0
    for component of @registeredComponents
      return false

    return true


  decorate: (data, decoratorList) ->
    for decorator in decoratorList
      decorator(data)
    return data


  modelToJSON: (model) ->
    return model.toJSON()


  modelsToJSON: (models) ->
    _.map models, @modelToJSON


  _validateContract: (dataToProduce) ->
    contract = @PRODUCTION_KEY.contract
    unless contract
      throw new Error "The subscriptionKey #{subscriptionKey.key} doesn't have a contract specified"

    return Vigor.helpers.validateContract(contract, dataToProduce, @, 'producing')


  extend: (obj, mixin) ->
    obj[name] = method for name, method of mixin
    return obj


  mixin: (instance, mixin) ->
    @extend instance, mixin


_.extend Producer.prototype, Backbone.Events
Producer.extend = Vigor.extend
Vigor.Producer = Producer