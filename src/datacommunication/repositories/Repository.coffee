#  ## Repository
#
# The Repository extends a [Backbone Collection](http://backbonejs.org/#Collection)
# and adds functionality for diffing and throttling data
#
#

class Repository extends Backbone.Collection

  _throttledAddedModels: undefined
  _throttledChangedModels: undefined
  _throttledRemovedModels: undefined

  # Reference to a [throttled](http://underscorejs.org/#throttle) version of the _triggerUpdates
  # function in order to avoid flooding the listeners
  _throttledTriggerUpdates: undefined

  initialize: ->
    @cid = @cid or _.uniqueId 'c'
    @_throttledAddedModels = {}
    @_throttledChangedModels = {}
    @_throttledRemovedModels = {}

    @_throttledTriggerUpdates = _.throttle @_triggerUpdates, 100, leading: no

    do @addThrottledListeners
    super

  # **addThrottledListeners** <br/>
  # Catch all events triggered from Backbone Collection in order make throttling possible
  addThrottledListeners: ->
    @on 'all', @_onAll

  # **getByIds** <br/>
  # @param [ids]: Array <br/>
  # @return models: Array
  getByIds: (ids) ->
    models = []
    for id in ids
      models.push @get id
    return models

  isEmpty: ->
    return @models.length <= 0

  _onAll: (event, args...) ->
    switch event
      when 'add' then @_onAdd.apply(@, args)
      when 'change' then @_onChange.apply(@, args)
      when 'remove' then @_onRemove.apply(@, args)

    do @_throttledTriggerUpdates

  _onAdd: (model) =>
    @_throttledAddedModels[model.id] = model

  _onChange: (model) =>
    @_throttledChangedModels[model.id] = model

  _onRemove: (model) =>
    @_throttledRemovedModels[model.id] = model

  _throttledAdd: ->
    event = Repository::REPOSITORY_ADD
    models = _.values @_throttledAddedModels
    @_throttledAddedModels = {}
    @_throttledEvent event, models, event

  _throttledChange: ->
    event = Repository::REPOSITORY_CHANGE
    models = _.values @_throttledChangedModels
    @_throttledChangedModels = {}
    @_throttledEvent event, models, event

  _throttledRemove: ->
    event = Repository::REPOSITORY_REMOVE
    models = _.values @_throttledRemovedModels
    @_throttledRemovedModels = {}
    @_throttledEvent event, models, event

  _throttledEvent: (event, models, eventRef) ->
    if models.length > 0
      @trigger event, models, eventRef
    return models


  # **_throttledDiff** <br/>
  # @param [added]: Array <br/>
  # @param [changed]: Array <br/>
  # @param [removed]: Array <br/>
  #
  # An event type called REPOSITORY_DIFF is added to the repository which supplies a consolidated
  # response with all the added, removed and updated models since last throttled batch
  _throttledDiff: (added, changed, removed) ->
    event = Repository::REPOSITORY_DIFF
    if  added.length or \
        changed.length or \
        removed.length

      added = _.difference(added, removed)
      consolidated = _.uniq added.concat(changed)

      models =
        added: added
        changed: changed
        removed: removed
        consolidated: consolidated

      @trigger event, models, event

  _triggerUpdates: =>
    @_throttledDiff @_throttledAdd(), @_throttledChange(), @_throttledRemove()

  REPOSITORY_DIFF: 'repository_diff'
  REPOSITORY_ADD: 'repository_add'
  REPOSITORY_CHANGE: 'repository_change'
  REPOSITORY_REMOVE: 'repository_remove'

Vigor.Repository = Repository