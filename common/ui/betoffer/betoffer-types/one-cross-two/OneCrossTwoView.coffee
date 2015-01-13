define (require) ->

	$ = require 'jquery'
	BaseBetofferView = require '../../BaseBetofferView'
	NoLabelOutcomeView = require '../../outcome-types/no-label/NoLabelOutcomeView'
	OutcomeTypes = require('common/constants').OutcomeTypes
	tmpl = require 'hbs!./templates/OneCrossTwo'

	class OneCrossTwoView extends BaseBetofferView

		className: 'modularized__outcomes-container modularized__three-column'
		$_leftCol: undefined
		$_middleCol: undefined
		$_rightCol: undefined


		#----------------------------------------------
		# Public methods
		#----------------------------------------------
		render: ->
			@$el.html tmpl(@viewModel.betoffer.toJSON())
			@$_leftCol = $ '.modularized__column-left', @el
			@$_middleCol = $ '.modularized__column-middle', @el
			@$_rightCol = $ '.modularized__column-right', @el

			do @_renderOutcomes
			return @


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