define (require) ->

	Q = require 'lib/q'
	Backbone = require 'lib/backbone'
	CurrencyUtil = require 'utils/CurrencyUtil'

	class ComponentView extends Backbone.View

		uglyWorkarounds: undefined
		renderDeferred: undefined
		viewModel: undefined

		constructor: (options) ->
			@uglyWorkarounds = options.uglyWorkarounds
			do @_setupPromises

			# These methods are required to make our view code
			# structure more consistent (just make them empty if
			# you don't need them).
			@_checkIfImplemented [
				'renderStaticContent',
				'addSubscriptions',
				'removeSubscriptions',
				'dispose'
			]

			super

		initialize: (options) ->
			super
			if options.viewModel
				@viewModel = options.viewModel

		render: ->
			do @renderStaticContent
			do @addSubscriptions
			@

		getRenderDonePromise: ->
			@renderDeferred.promise

		# Override this.
		# Render parts of component that don't rely on model.
		renderStaticContent: ->
			return

		# Override this.
		# Add view model subscriptions if needed.
		addSubscriptions: ->
			return

		# Override this.
		# Remove view model subscriptions.
		removeSubscriptions: ->
			return

		# Override this, and call super.
		dispose: ->
			do @model?.unbind
			do @removeSubscriptions
			do @stopListening
			do @$el.off
			do @$el.remove
			do @off

		_setupPromises: ->
			@renderDeferred = do Q.defer

		_checkIfImplemented: (methodNames) =>
			for methodName in methodNames
				unless this.constructor.prototype.hasOwnProperty(methodName)
					#throw new Error(this.constructor.name + ' - ' + methodName + '() must be implemented in View.')
					console.log 'FIXME: ' + this.constructor.name + ' - ' + methodName + '() must be implemented in View.'

	return ComponentView