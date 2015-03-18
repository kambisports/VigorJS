define (require) ->

	_ = require 'lib/underscore'
	PackageBase = require 'common/PackageBase'
	MostPopularView = require './MostPopularView'
	MostPopularViewModel = require './MostPopularViewModel'
	MostPopularEvents = require './MostPopularEvents'

	class MostPopular extends PackageBase

		# private properties
		$el: undefined
		_viewModel: undefined
		_mostPopularView: undefined

		#----------------------------------------------
		# Public methods
		#----------------------------------------------
		constructor: ->
			super
			@_viewModel = new MostPopularViewModel()
			@_mostPopularView = new MostPopularView
				viewModel: @_viewModel

			@_mostPopularView.on MostPopularEvents.EMPTY, @_onEmpty

		render: ->
			@$el = @_mostPopularView.render().$el
			_.defer =>
				do @renderDeferred.resolve
			return @

		dispose: =>
			do @_mostPopularView?.dispose
			@_mostPopularView = undefined
			@_viewModel?.dispose false
			@_viewModel = undefined

		_onEmpty: =>
			@trigger MostPopularEvents.EMPTY

		NAME: 'MostPopular'
		EVENTS: MostPopularEvents

	return MostPopular
