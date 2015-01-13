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
			super

		initialize: (options) ->
			super
			if options.viewModel
				@viewModel = options.viewModel

		formatAsCurrency: (value) ->
			return CurrencyUtil.formatCurrencyWithSymbol value, @uglyWorkarounds.getCurrency()

		getRenderDonePromise: ->
			return @renderDeferred.promise

		dispose: ->
			do @model?.unbind
			do @stopListening
			do @$el.off
			do @$el.remove
			do @off

		_setupPromises: ->
			@renderDeferred = Q.defer()

	return ComponentView