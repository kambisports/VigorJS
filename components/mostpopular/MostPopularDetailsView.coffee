define (require) ->

	$ = require 'jquery'
	_ = require 'lib/underscore'
	Handlebars = require 'hbs/handlebars'
	ComponentView = require 'common/ComponentView'
	CapabilityUtil = require 'utils/CapabilityUtil'
	StringUtil = require 'utils/StringUtil'
	tmpl = require 'hbs!./templates/MostPopularDetails'

	class MostPopularDetails extends ComponentView

		events:
			'change .modularized__stake-selector': '_onStakeSelectorChange'

		$_potentialPayout: undefined
		$_stakeSelector: undefined
		$addToBetslipBtn: undefined
		_potentialPayoutPartial: undefined


		#----------------------------------------------
		# Public methods
		#----------------------------------------------
		initialize: (options) ->
			@viewModel = options.viewModel
			@_potentialPayoutPartial = Handlebars.compile("{{formatCurrencyWithSymbol potentialPayout}}")
			@listenTo @viewModel.defaultStakes, 'change:stakes', @render
			@listenTo @viewModel.selectedOutcomes, 'reset', @_onSelectedOutcomesChange
			super


		render: ->
			templateData =
				stakeLabel: 'mostpopular.details.stake'
				potentialPayoutLabel: 'mostpopular.details.potentialpayout'
				addToBetslipLabel: 'mostpopular.details.addtobetslip'
				stakes: @_getFormattedStakes()
				potentialPayout: 0
				supportsSelect: CapabilityUtil.supportsSelect()

			@$el.html tmpl(templateData)

			@$_potentialPayout = $ '.modularized__popular-potential-payout', @el
			@$_stakeSelector = $ '.modularized__stake-selector', @el
			@$addToBetslipBtn = $ '.modularized__add-to-betslip-btn', @el

			if @$_stakeSelector.length and (typeof @$_stakeSelector.get(0).style.webkitAppearance isnt 'undefined')
				@$_stakeSelector.addClass 'custom-skin'

			return @


		getStake: ->
			return @$_stakeSelector.val()

		enableAddToBetslip: ->
			@$addToBetslipBtn.removeClass 'disabled'

		disableAddToBetslip: ->
			@$addToBetslipBtn.addClass 'disabled'

		isDisabled: ->
			return @$addToBetslipBtn.hasClass 'disabled'

		updatePotentialPayout: ->
			potentialPayout = @viewModel.getPotentialPayout(@getStake())
			@$_potentialPayout.html @_potentialPayoutPartial({potentialPayout: potentialPayout})


		#----------------------------------------------
		# Private methods
		#----------------------------------------------
		_getFormattedStakes: ->
			_.map @viewModel.defaultStakes.get('stakes'), (stake) ->
				label: stake
				value: stake

		_hideStakeInput: ->
			@$el.addClass 'modularized__hide-stake-selection'


		#----------------------------------------------
		# Callbacks
		#----------------------------------------------
		_onStakeSelectorChange: ->
			do @updatePotentialPayout

		_onSelectedOutcomesChange: ->
			do @updatePotentialPayout

	return MostPopularDetails
