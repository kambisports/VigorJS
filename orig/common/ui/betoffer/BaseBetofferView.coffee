define (require) ->

	$ = require 'jquery'
	BetofferModel = require './BetofferModel'
	ComponentView = require 'common/ComponentView'
	BasicOutcomeView = require './outcome-types/basic/BasicOutcomeView'
	BetofferEvents = require './BetofferEvents'

	class BaseBetofferView extends ComponentView

		tagName: 'div'
		className: 'modularized__outcomes-container modularized__js-outcomes-container'
		events:
			'click .modularized__js-outcome': '_onOutcomeClick'

		outcomes: undefined
		outcomesAsRadioBtns: false

		#----------------------------------------------
		# Public methods
		#----------------------------------------------

		initialize: (options) ->
			super
			if options.outcomesAsRadioBtns
				@outcomesAsRadioBtns = options.outcomesAsRadioBtns

			@outcomes = []
			do @_createOutcomes

		deselectOutcomes: ->
			@viewModel.outcomes.each (outcome) ->
				outcome.set 'highlight', false

		dispose: ->
			for outcome in @outcomes
				do outcome.dispose
				outcome = undefined
			@outcomes = undefined
			super

		#----------------------------------------------
		# Private methods
		#----------------------------------------------
		_createOutcomes: ->
			@viewModel.outcomes.each (outcomeModel) =>
				outcome = new BasicOutcomeView
					model: outcomeModel

				@outcomes.push outcome

		_selectOutcome: (outcomeId) ->
			outcome = @viewModel.outcomes.findWhere(id: outcomeId)
			wasHighlighted = outcome.get 'highlight'

			if @outcomesAsRadioBtns then do @deselectOutcomes

			eventData =
				betofferId: @viewModel.betoffer.get('id')
				outcomeId: outcomeId
				selected: false

			if wasHighlighted
				eventData.selected = false
				outcome.set 'highlight', false

			else
				eventData.selected = true
				outcome.set 'highlight', true

			@$el.trigger BetofferEvents.OUTCOME_CLICK, eventData


		#----------------------------------------------
		# Callbacks
		#----------------------------------------------
		_onOutcomeClick: (event) ->
			outcomeId = $(event.currentTarget).data('outcome-id')
			@_selectOutcome outcomeId

	return BaseBetofferView