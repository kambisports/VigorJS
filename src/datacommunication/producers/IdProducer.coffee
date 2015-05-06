class IdProducer extends Producer

  updatedIds: undefined
  subscriptions: undefined

  # the type of the internal ids should be value types, and are numbers by default
  # trying to add a subscription with an invalid type throws an error
  idType: typeof 0


  constructor: ->
    super
    @updatedIds = []

    # TODO: make this an ES6 Map so we can have keys of arbitrary types,
    # and then remove idType
    @subscriptions = {}


  subscribe: (options) ->
    id = @idForOptions options
    if typeof id isnt @idType
      throw "expected the subscription key to be a #{@idType} but got a #{typeof subscriptionKey}"
    if @subscriptions[id]
      @subscriptions[id].push options
    else
      @subscriptions[id] = [options]

    @produceDataSync id


  onDiffInRepository: (repository, diff) ->
    self = @

    addRemoveMap = (model) ->
      id = self.idForModel model, repository
      if self.hasId id
        id

    changeMap = (model) ->
      id = self.idForModel model, repository
      if (self.hasId id) and (self.shouldPropagateModelChange model, repository)
        id

    addedModelIds = _.map diff.added, addRemoveMap
    removedModelIds = _.map diff.removed, addRemoveMap
    updatedModelIds = _.map diff.changed, changeMap

    @produceDataForIds _.filter _.flatten [addedModelIds, removedModelIds, updatedModelIds]


  produceDataForIds: (ids = @allIds()) ->
    @updatedIds = _.uniq @updatedIds.concat ids
    @produceData()


  allIds: ->
    ids = _.keys @subscriptions

    if @idType is (typeof 0)
      ids = _.map ids, (id) ->
        parseInt id, 10

    ids


  produceDataSync: (id) ->
    if id?
      @produce [id]

    else if @updatedIds.length > 0
      ids = @updatedIds.slice()
      @updatedIds.length = 0

      @produce ids


  unsubscribe: (options) ->
    id = @idForOptions options
    subscription = @subscriptions[id]
    if subscription?
      index = subscription.indexOf options
      unless index is -1
        subscription.splice index, 1

        if subscription.length is 0
          delete @subscriptions[id]


  produce: (ids) ->
    for id in ids

      data = @decorate { id: id }
      @_validateContract data

      _.each @registeredComponents, (component) ->
        if id is @idForOptions component.options
          component.callback data
      , @


  hasId: (id) ->
    @subscriptions[id]?


  shouldPropagateModelChange: (model, repository) ->
    true


  idForModel: (model, repository) ->
    model.id


  idForOptions: (options) ->
    options.id


Vigor.IdProducer = IdProducer