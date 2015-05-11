class ComponentBase

  render: ->
    throw 'ComponentBase->render needs to be over-ridden'

  dispose: ->
    throw 'ComponentBase->dispose needs to be over-ridden'

_.extend ComponentBase.prototype, Backbone.Events

ComponentBase.extend = Vigor.extend
Vigor.ComponentBase = ComponentBase