# ##ComponentView
# This class is intended to be used as a base class for all views within a component
# It enforces five methods to unify the structure of ComponentViews accross a large application:
#
# - renderStaticContent
# - renderDynamicContent
# - addSubscriptions
# - removeSubscriptions
# - dispose
#

class ComponentView extends Backbone.View

  # @property viewModel: ComponentViewModel
  viewModel: undefined

  # **constructor** <br/>
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

  # **initialize** <br/>
  # @param object <br/>
  # @return this: Object <br/>
  # view options, usually containing a viewModel instance <br/>
  initialize: (options) ->
    super
    if options?.viewModel
      @viewModel = options.viewModel
    return @

  # **render** <br/>
  # @return this: Object <br/>
  # the views render method, it will call @renderStaticContent and @addSubscriptions <br/>
  render: ->
    do @renderStaticContent
    do @addSubscriptions
    return @

  # **renderStaticContent** <br/>
  # @return this: Object <br/>
  # Override this. <br/>
  # Render parts of component that don't rely on model. <br/>
  renderStaticContent: ->
    return @

  # **renderDynamicContent** <br/>
  # @return this: Object <br/>
  # Override this. <br/>
  # Render parts of component that relies on model. <br/>
  renderDynamicContent: ->
    return @

  # **addSubscriptions** <br/>
  # @return this: Object <br/>
  # Override this. <br/>
  # Add view model subscriptions if needed. <br/>
  addSubscriptions: ->
    return @

  # **removeSubscriptions** <br/>
  # @return this: Object <br/>
  # Override this. <br/>
  # Remove view model subscriptions.
  removeSubscriptions: ->
    return @

  # **dispose** <br/>
  # Removes events and dom elements related to the view <br/>
  # Override this, and call super.
  dispose: ->
    do @model?.unbind
    do @removeSubscriptions
    do @stopListening
    do @$el.off
    do @$el.remove
    do @off

  # **_checkIfImplemented** <br/>
  # @param array: Array <br/>
  # Ensures that passed methods are implemented in the view
  _checkIfImplemented: (methodNames) ->
    for methodName in methodNames
      unless @constructor.prototype.hasOwnProperty(methodName)
        throw new Error("#{@constructor.name} - #{methodName}() must be implemented in View.")

# Expose ComponentView on the Vigor object
Vigor.ComponentView = ComponentView
