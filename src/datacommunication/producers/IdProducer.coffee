# ## IdProducer
#
# An IdProducer produces data for multiple models.
#
# When an ordinary producer produces data, it produces all of its data to all of its subscribers.<br/>
# An IdProducer produces data for multiple data models, each of which has its own id.
# A subscription to an IdProducer specifies an id which corresponds to the model it is interested in.
# When a model's data changes, the IdProducer produces the data for that model to the subscribers that
# are subscribed to that model's id.


class IdProducer extends Producer

  # An array containing the ids of the models that have been added, removed
  # or updated since the last time data was produced
  updatedIds: undefined

  # A map of the subscriptions to this producer. The keys of this map are model ids
  # and the values are arrays of subscription options objects.
  subscriptions: undefined

  # This is the type of the model ids.<br/>
  # This should be value types, and are numbers by default.<br/>
  # Trying to add a subscription with an invalid type throws an error.
  idType: typeof 0


  constructor: ->
    super
    @updatedIds = []
    @subscriptions = {}


  # **subscribe**<br/>
  # @param [options]: Object<br/>
  # Subsciption options. Can be used to get the id to unsubscribe from.
  #
  # Subscribe to the producer, if the id is of valid type.
  subscribe: (options) ->
    id = @idForOptions options
    if typeof id isnt @idType
      throw "expected the subscription key to be a #{@idType} but got a #{typeof subscriptionKey}"
    if @subscriptions[id]
      @subscriptions[id].push options
    else
      @subscriptions[id] = [options]

    @produceDataSync id

  # **onDiffInRepository**<br/>
  # @param [repository]: [Repository](Repository.html)<br/>
  # The repository whose data changed.
  #
  # @param [diff]: Object<br/>
  # An object containing arrays of data items that were added, removed and changed
  #
  # Handles updates from repositories. Filters the given models to only those that have subscriptions
  # and produces data for them.
  onDiffInRepository: (repository, diff) ->
    self = @

    addRemoveMap = (model) ->
      id = self.idForModel model, repository
      if _.isArray id
        _.filter id, self.hasId.bind self
      else if self.hasId id
        id

    changeMap = (model) ->
      id = self.idForModel model, repository
      if self.shouldPropagateModelChange model, repository
        if _.isArray id
          _.filter id, self.hasId.bind self
        else if self.hasId id
          id

    addedModelIds = _.map diff.added, addRemoveMap
    removedModelIds = _.map diff.removed, addRemoveMap
    updatedModelIds = _.map diff.changed, changeMap

    @produceDataForIds _.filter _.flatten [addedModelIds, removedModelIds, updatedModelIds]


  # **produceDataForIds**<br/>
  # @param [ids]: Array of idTypes<br/>
  # An array of model ids to produce data for. Defaults to all subscribed models.<br/>
  #
  # Produces data for all given model ids.
  produceDataForIds: (ids = @allIds()) ->
    @updatedIds = _.uniq @updatedIds.concat ids
    @produceData()

  # **allIds**<br/>
  # @returns [ids]: Array of idTypes<br/>
  # All subscribed ids.
  #
  # Returns an array of all subscribed ids.
  allIds: ->
    ids = _.keys @subscriptions

    if @idType is (typeof 0)
      ids = _.map ids, (id) ->
        parseInt id, 10

    ids

  # **produceData**<br/>
  # Aynchronously produces data for all models whose data has changed since the last time data was produced.

  # **produceDataSync**<br/>
  # @param [id]: idType<br/>
  # The id to produce data for. Defaults to all ids whose data has changed since the last time data was produced.
  #
  # Synchronously produces data for all models whose data has changed since the last time data was produced. If an id is supplied, only data for the model with that id is produced.
  produceDataSync: (id) ->
    if id?
      @produce [id]

    else if @updatedIds.length > 0
      ids = @updatedIds.slice()
      @updatedIds.length = 0

      @produce ids


  # **unsubscribe** <br/>
  # @param [options]: Object <br/>
  # Subsciption options. Can be used to get the id to unsubscribe from. This must be the same reference as the options used when subscribing (i.e. ===).
  #
  # Unsubscribe from the producer.
  unsubscribe: (options) ->
    id = @idForOptions options
    subscription = @subscriptions[id]
    if subscription?
      index = subscription.indexOf options
      unless index is -1
        subscription.splice index, 1

        if subscription.length is 0
          delete @subscriptions[id]

  # **produce**<br/>
  # @param [ids]: Array of idTypes<br/>
  # List of ids to produce data for.
  #
  # Produce (gathered, decorated and validated) data for the ids.
  produce: (ids) ->
    for id in ids

      data = @currentData(id) or {}
      data.id = id
      data = @decorate data

      @_validateContract data

      _.each @registeredComponents,
        _.bind (component) ->
          if id is @idForOptions component.options
            component.callback data
        , @

  # **currentData**<br/>
  # @param [id]: The id to produce data for
  #
  # This is where the actual collection of the data is done. <br/>
  currentData: (id) ->
    # default implementation is a noop

  # **hasId**<br/>
  # @param [id]: idType<br/>
  # The id to check for.
  #
  # @returns [hasId]: boolean<br/>
  # True if there is a subscription for the given id, false otherwise.
  #
  # Returns true if there is a subscription for the given id, otherwise returns false.
  hasId: (id) ->
    @subscriptions[id]?


  # **shouldPropagateModelChange**<br/>
  # @param [model]: Object<br/>
  # A model
  #
  # @param [repository]: [Repository](Repository.html)<br/>
  # The repository which contains the model.<br/>
  #
  # Called when a model changes to determine whether to produce data for the model. If true, then data for the model will be produced for this change.
  shouldPropagateModelChange: (model, repository) ->
    true

  # **idForModel**<br/>
  # @param [model]: Object<br/>
  # A model
  #
  # @param [repository]: [Repository](Repository.html)<br/>
  # The repository which contains the model.
  #
  # @returns [id]: idType or array of idTypes<br/>
  # The internal id of the given model, or an array of internal ids which correspond to the given model.
  #
  # Translates a model to an id or array of ids of type idType which uniquely identifies the model internally to this producer.
  idForModel: (model, repository) ->
    model.id

  # **idForOptions**<br/>
  # @param [options]: Object<br/>
  # A subscription options object.
  #
  # @returns [id]: idType<br/>
  # The internal id of the model that the subscription options refer to.
  #
  # Translates subscription options to an id of type idType which uniquely identifies the model internally to this producer.
  idForOptions: (options) ->
    options.id


Vigor.IdProducer = IdProducer
