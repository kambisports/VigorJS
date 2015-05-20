# ## Producer
#
# A Producer listens to data changes in one or several repositories
# and produces data on a certain Production Key.
#
#

class Producer

  # The production key that is used for subscribing to the producer. <br/>
  # This key should be overridden in the subclass.
  PRODUCTION_KEY: undefined

  # The repository (or repositories) that the producer listens to.
  repositories: []

  # The decorator(s) that is used for formatting the produced data.
  decorators: []

  # Keeps track of if the producer has subscribed to its repositories or not.
  _isSubscribedToRepositories: false


  constructor: ->
    @registeredComponents = {}
    @produceData = _.throttle @produceDataSync, 100


  getInstance: ->
    unless @instance?
      @instance = new @constructor()
    @instance


  # **addComponent** <br/>
  # @param [subscription]: Object <br/>
  # The subscription, which contains an id, a callback and options. <br/>
  #
  # Adds (subscribes) a component to the producer.
  addComponent: (subscription) ->
    existingSubscription = @registeredComponents[subscription.id]
    unless existingSubscription?
      @registeredComponents[subscription.id] = subscription
      @subscribe subscription.options

      unless @_isSubscribedToRepositories
        @subscribeToRepositories()
        @_isSubscribedToRepositories = true


  # **removeComponent** <br/>
  # @param [componentId]: String <br/>
  # The id of the component that should be removed. <br/>
  #
  # Removes a component (its subscription) from the producer.
  removeComponent: (componentId) ->
    subscription = @registeredComponents[componentId]

    if subscription?
      @unsubscribe subscription.options
      delete @registeredComponents[subscription.id]

      shouldUnsubscribe = true
      for component of @registeredComponents
        shouldUnsubscribe = false
        break

      if shouldUnsubscribe
        @unsubscribeFromRepositories()
        @_isSubscribedToRepositories = false


  # **subscribeToRepositories** <br/>
  # Subscribes to all the repositories. <br/>
  # Also registers the callback function if the repository has one.
  subscribeToRepositories: ->
    for repository in @repositories
      if repository instanceof Vigor.Repository
        @subscribeToRepository repository
      else if repository.repository instanceof Vigor.Repository and typeof repository.callback is 'string'
        @subscribeToRepository repository.repository, @[repository.callback]
      else
        throw 'unexpected format of producer repositories definition'


  # **unsubscribeFromRepositories** <br/>
  # Unsubscribes from all the repositories.
  unsubscribeFromRepositories: ->
    for repository in @repositories
      if repository instanceof Vigor.Repository
        @unsubscribeFromRepository repository
      else if repository.repository instanceof Vigor.Repository and typeof repository.callback is 'string'
        @unsubscribeFromRepository repository.repository
    undefined


  # **subscribeToRepository** <br/>
  # @param [repository]: Object <br/>
  # The repository to subscribe to. <br/>
  # @param [callback]: String <br/>
  # The method that should be executed on repository diff.
  #
  # Sets up a subscription to a repository with a custom or predefined callback.
  subscribeToRepository: (repository, callback) ->
    callback = callback or (diff) =>
      @onDiffInRepository repository, diff

    @listenTo repository, Vigor.Repository::REPOSITORY_DIFF, callback


  # **unsubscribeFromRepository** <br/>
  # @param [repository]: Object <br/>
  # The repository to unsubscribe from.
  #
  # Unsubscribes from a repository.
  unsubscribeFromRepository: (repository) ->
    @stopListening repository, Vigor.Repository::REPOSITORY_DIFF


  # **subscribe** <br/>
  # Called when a component is added.
  subscribe: ->
    @produceDataSync()


  # **onDiffInRepository** <br/>
  # Used as default callback when subscribing to a repository.
  onDiffInRepository: =>
    @produceData()


  produceDataSync: ->
    @produce @currentData()


  # ***produce*** <br/>
  # @param [data]: Object <br/>
  # The current data.
  #
  # This method is called by the produceDataSync method <br/>
  # and in turn calls methods for decoration of the current data <br/>
  # and validation of its contract.
  produce: (data) ->
    data = @decorate data
    @_validateContract data
    (component.callback data) for componentId, component of @registeredComponents


  # **currentData** <br/>
  # This is where the actual collection of the data is done. <br/>
  # Default implementation is a noop.
  currentData: ->

  # **unsubscribe** <br/>
  # Default implementation is a noop.
  unsubscribe: (options) ->


  # **decorate** <br/>
  # @param [data]: Object <br/>
  # The data to decorate .<br/>
  # @return data: Object <br/>
  # The decorated data.
  #
  # Runs the assigned decorator(s) on the data.
  decorate: (data) ->
    for decorator in @decorators
      decorator data
    data


  modelToJSON: (model) ->
    return model.toJSON()


  modelsToJSON: (models) ->
    _.map models, @modelToJSON


  # **_validateContract** <br/>
  # @param [dataToProduce]: Object <br/>
  # The data to validate. <br/>
  # @return : Boolean
  #
  # Used to validate data against a predefined contract, if there is one.
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