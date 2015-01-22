define (require) ->

	$ = require 'jquery'
	_ = require 'lib/underscore'

	ComponentView = require 'common/ComponentView'
	GUIUtil = require 'utils/GUIUtil'
	DOMUtil = require 'utils/DOMUtil'
	EventItem = require 'common/ui/event-item'
	Betoffer = require 'common/ui/betoffer'
	BetofferEvents = require('common/constants').BetofferEvents
	EventBus = require 'common/EventBus'
	EventKeys = require 'datacommunication/EventKeys'

	MostPopularEvents = require('common/constants').MostPopularEvents
	MostPopularDetails = require './MostPopularDetailsView'
	tmpl = require 'hbs!./templates/MostPopular'

	class MostPopularView extends ComponentView

		className: 'modularized__most-popular'
		renderDeferred: undefined
		events:
			'click .modularized__add-to-betslip-btn': '_onAddToBetslipClick'

		#--------------------------------------
		#	Private properties
		#--------------------------------------
		_viewModel: undefined
		$_spinner: undefined
		$_eventsList: undefined
		$_details: undefined

		_details: undefined
		_eventItems: undefined
		_betoffers: undefined
		_loadingSpinner: undefined
		_spinnerTimeout: undefined
		_spinnerTimeoutDelay: 3000


		#----------------------------------------------
		# Public methods
		#----------------------------------------------
		constructor: ->
			@events = @events or {}
			@events[BetofferEvents.OUTCOME_CLICK] = '_onOutcomeClick'
			super


		initialize: (options) ->
			@_viewModel = options.viewModel
			@_betoffers = []
			@_eventItems = []

			@listenTo @_viewModel.selectedOutcomes, 'reset', @_onViewModelDataLoaded
			do @_viewModel.addSubscriptions

			super

		render: ->
			@$el.html tmpl
				labelLeft: 'mostpopular.outcomeLabel.home'
				labelMiddle: 'mostpopular.outcomeLabel.draw'
				labelRight: 'mostpopular.outcomeLabel.away'

			@$_spinner = $ '.modularized__most-popular__spinner', @el
			@$_eventsList = $ '.modularized__event-list', @el
			@$_details = $ '.modularized__most-popular__details', @el

			do @_showSpinner
			do @_renderDetails
			do @disableAddToBetslip

			do @createEventItems

			_.defer =>
				do @renderDeferred.resolve

			return @


		dispose: ->
			for item in @_eventItems
				do item.dispose
				item = undefined

			for betoffer in @_betoffers
				do betoffer.dispose
				betoffer = undefined

			do @$_eventsList.remove
			do @_details.dispose

			@_eventItems = undefined
			@_betoffers = undefined
			@_details = undefined

			super


		createEventItems: ->
			events = @_viewModel.events

			unless events and events.length
				@trigger MostPopularEvents.EMPTY
				return

			asRadioBtns = true
			for event in events
				eventItem = new EventItem(event.eventId)

				betoffer = new Betoffer(event.betofferId, asRadioBtns)
				eventItem.addBetoffer betoffer
				@_betoffers.push betoffer

				@_eventItems.push eventItem
				@$_eventsList.append eventItem.render()

			do @enableAddToBetslip
			do @_hideSpinner
			do DOMUtil.forcePaintDelayed


		enableAddToBetslip: ->
			do @_details.enableAddToBetslip


		disableAddToBetslip: ->
			do @_details.disableAddToBetslip


		#----------------------------------------------
		# Private methods
		#----------------------------------------------
		_setBetoffersOutcomeState: ->
			@_viewModel.selectedOutcomes.reset @_getSelectedOutcomes()
			do @_updateAddToBetslipState


		_getSelectedOutcomes: ->
			_.flatten _.map @_betoffers, (betoffer) ->
				betoffer.getSelectedOutcomes()


		_updateAddToBetslipState: ->
			hasSelectedOutcomes = !!$('.modularized__outcome.highlighted', @el).length
			if hasSelectedOutcomes then do @enableAddToBetslip
			else do @disableAddToBetslip


		_showSpinner: ->
			clearTimeout @_spinnerTimeout
			@_spinnerTimeout = setTimeout =>
				do @$_spinner.show
				unless @_loadingSpinner
					@_loadingSpinner = GUIUtil.createDefaultLoadingSpinner @$_spinner
			, @_spinnerTimeoutDelay


		_hideSpinner: ->
			clearTimeout @_spinnerTimeout
			do @$_spinner.hide
			do @_loadingSpinner?.stop
			@_loadingSpinner = undefined


		_renderDetails: ->
			@_details = new MostPopularDetails
				el: @$_details
				viewModel: @_viewModel

			do @_details.render


		_addSelectedOutcomesToBetslip: ->
			betslipData =
				stake: do @_details.getStake
				outcomes: do @_getSelectedOutcomes

			EventBus.send EventKeys.ADD_OUTCOMES_TO_BETSLIP_REQUESTED, betslipData

		#----------------------------------------------
		# Callbacks
		#----------------------------------------------
		_onAddToBetslipClick: ->
			if @_details.isDisabled() then return
			do @_addSelectedOutcomesToBetslip

		_onOutcomeClick: ->
			do @_setBetoffersOutcomeState

		_onViewModelDataLoaded: =>
			do @render

	return MostPopularView