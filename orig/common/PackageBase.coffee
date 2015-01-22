define (require) ->

	Q = require 'lib/q'
	_ = require 'lib/underscore'
	Backbone = require 'lib/backbone'

	class PackageBase

		renderDeferred: undefined

		constructor: ->
			@renderDeferred = Q.defer()
			_.extend @, Backbone.Events

		render: ->
			throw 'PackageBase->render needs to be over-ridden'

		dispose: ->
			throw 'PackageBase->dispose needs to be over-ridden'

		getRenderDonePromise: ->
			return @renderDeferred.promise

	return PackageBase