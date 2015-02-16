define (require) ->

	$ = require 'jquery'
	BaseBetofferView = require '../../BaseBetofferView'
	NoLabelOutcomeView = require '../../outcome-types/no-label/NoLabelOutcomeView'
	OutcomeTypes = require '../../outcome-types/OutcomeTypes'
	tmpl = require 'hbs!./templates/OneCrossTwo'

	class OneCrossTwoView extends BaseBetofferView

		className: 'modularized__outcomes-container modularized__outcomes-container--three-column'
		$_leftCol: undefined
		$_middleCol: undefined
		$_rightCol: undefined


		#----------------------------------------------
		# Public methods
		#----------------------------------------------
		addSubscriptions: ->
			super

		removeSubscriptions: ->
			super

		renderStaticContent: ->
			@$el.html tmpl(@viewModel.betoffer.toJSON())
			@$_leftCol = $ '.modularized__js-column-left', @el
			@$_middleCol = $ '.modularized__js-column-middle', @el
			@$_rightCol = $ '.modularized__js-column-right', @el
			do @_renderOutcomes

		renderDynamicContent: ->
			super

		dispose: ->
			@$_leftCol = undefined
			@$_middleCol = undefined
			@$_rightCol = undefined
			super

		#----------------------------------------------
		# Private methods
		#----------------------------------------------
		_createOutcomes: ->
			@viewModel.outcomes.each (outcomeModel) =>
				outcome = new NoLabelOutcomeView
					model: outcomeModel

				@outcomes.push outcome

		_renderOutcomes: ->
			for outcome in @outcomes
				switch outcome.model.get('type')
					when OutcomeTypes.TYPE_ONE
						@$_leftCol.append outcome.render().$el

					when OutcomeTypes.TYPE_CROSS
						@$_middleCol.append outcome.render().$el

					when OutcomeTypes.TYPE_TWO
						@$_rightCol.append outcome.render().$el

	return OneCrossTwoView