define (require) ->

	_ = require 'lib/underscore'
	PackageBase = require 'common/PackageBase'
	BetFeedbackView = require './BetFeedbackView'
	BetFeedbackViewModel = require './BetFeedbackViewModel'

	class BetFeedback extends PackageBase

		$el: undefined

		viewModel: undefined
		view: undefined

		#----------------------------------------------
		# Public methods
		#----------------------------------------------
		constructor: ->
			super

			# create a new view model, which has no references to data at this point
			@viewModel = new BetFeedbackViewModel()

			# create a view for displaying the data from the view model
			@view = new BetFeedbackView
				viewModel: @viewModel

		render: ->
			# render is super simple; this could probably be the default implementation
			# in the superclass
			@$el = @view.render().$el
			_.defer =>
				do @renderDeferred.resolve
			return @

		dispose: ->
			# dispose the view, which will dispose down the hierarchy
			do @view.dispose

			# clean up references
			@view = undefined
			@model = undefined

	return BetFeedback
