class PackageBase

  constructor: ->
    _.extend @, Backbone.Events
    console.log 'yey'

  render: ->
    throw 'PackageBase->render needs to be over-ridden'

  dispose: ->
    throw 'PackageBase->dispose needs to be over-ridden'


PackageBase.extend = Vigor.extend
Vigor.PackageBase = PackageBase