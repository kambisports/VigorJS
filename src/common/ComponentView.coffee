# ComponentView
# Base class for all component views
class ComponentView extends Backbone.View

  # A view model instance is usually passed to the view upon creation
  # @property [ViewModel<instance>]
  viewModel: undefined

  # Construct a new ComponentView
  constructor: ->
    # These methods are required to make our view code
    # structure more consistent (just make them empty if
    # you don't need them).
    @_checkIfImplemented [
      'renderStaticContent',
      'renderDynamicContent',
      'addSubscriptions',
      'removeSubscriptions',
      'dispose'
    ]

    super

  # @param [object] view options, usually containging a viewModel instance
  # @return [this]
  initialize: (options) ->
    super
    if options.viewModel
      @viewModel = options.viewModel
    return @

  # the views render method, it will call @renderStaticContent and @addSubscriptions
  # @return [this]
  render: ->
    do @renderStaticContent
    do @addSubscriptions
    return @

  # Override this.
  # Render parts of component that don't rely on model.
  # @return [this]
  renderStaticContent: ->
    return @

  # Override this.
  # Render parts of component that relies on model.
  # @return [this]
  renderDynamicContent: ->
    return @

  # Override this.
  # Add view model subscriptions if needed.
  # @return [this]
  addSubscriptions: ->
    return @

  # Override this.
  # Remove view model subscriptions.
  # @return [this]
  removeSubscriptions: ->
    return @

  # Override this, and call super.
  dispose: ->
    do @model?.unbind
    do @removeSubscriptions
    do @stopListening
    do @$el.off
    do @$el.remove
    do @off

  # Ensures that passed methods are implemented in the view
  _checkIfImplemented: (methodNames) ->
    for methodName in methodNames
      unless @constructor.prototype.hasOwnProperty(methodName)
        throw new Error("#{@constructor.name} - #{methodName}() must be implemented in View.")
        # console.log 'FIXME: ' + this.constructor.name + ' - ' + methodName + '() must be implemented in View.'

Vigor.ComponentView = ComponentView
