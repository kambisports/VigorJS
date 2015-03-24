class PackageBase

  render: ->
    throw 'PackageBase->render needs to be over-ridden'

  dispose: ->
    throw 'PackageBase->dispose needs to be over-ridden'

_.extend PackageBase.prototype, Backbone.Events

PackageBase.extend = Vigor.extend
Vigor.PackageBase = PackageBase