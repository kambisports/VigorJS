class Producer
  
  # the production key should be overridden in the subclass
  PRODUCTION_KEY: undefined
  repositories: []
  decorators: []

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

      # for..of is slightly faster than checking _.keys().length
      shouldUnsubscribe = true
      for component of @registeredComponents
        shouldUnsubscribe = false
        break

      if shouldUnsubscribe
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
    undefined


  subscribeToRepository: (repository, callback) ->
    callback = callback or (diff) =>
      @onDiffInRepository repository, diff

    @listenTo repository, Vigor.Repository::REPOSITORY_DIFF, callback


  unsubscribeFromRepository: (repository) ->
    @stopListening repository, Vigor.Repository::REPOSITORY_DIFF


  subscribe: ->
    @produceDataSync()


  onDiffInRepository: =>
    @produceData()


  produceDataSync: ->
    @produce @currentData()


  produce: (data) ->
    data = @decorate data
    @_validateContract data
    (component.callback data) for componentId, component of @registeredComponents


  currentData: ->
    # default implementation is a noop


  unsubscribe: (options) ->
    # default implementation is a noop


  decorate: (data) ->
    for decorator in @decorators
      decorator data
    data


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