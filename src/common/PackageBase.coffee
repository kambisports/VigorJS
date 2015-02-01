class PackageBase

	constructor: ->
		_.extend @, Backbone.Events

	render: ->
		throw 'PackageBase->render needs to be over-ridden'

	dispose: ->
		throw 'PackageBase->dispose needs to be over-ridden'

Vigor.PackageBase = PackageBase