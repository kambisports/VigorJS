define (require) ->

	PackageBase = require 'common/PackageBase'
	BetofferViewModel = require './BetofferViewModel'
	BaseBetofferView = require './BaseBetofferView'
	OneCrossTwoView = require './betoffer-types/one-cross-two/OneCrossTwoView'
	BetofferTypes = require './betoffer-types/BetofferTypes'
	BetofferEvents = require './BetofferEvents'

	class Betoffer extends PackageBase

		# private properties
		_viewModel: undefined
		_betoffer: undefined
		_outcomesAsRadioBtns: undefined

		# public properties
		betofferId: undefined

		#----------------------------------------------
		# Public methods
		#----------------------------------------------
		constructor: (@betofferId, @_outcomesAsRadioBtns = false) ->
			super
			@_viewModel = new BetofferViewModel @betofferId

			@_viewModel.betoffer.on 'change', @_onViewModelDataLoaded, @
			@_viewModel.addSubscriptions()

		render: ->
			return @renderDeferred.promise

		createBetoffer: (betofferData) ->
			BetofferClass = @_getBetofferClass betofferData.betofferType.id
			@_betoffer = new BetofferClass
				viewModel: @_viewModel
				outcomesAsRadioBtns: @_outcomesAsRadioBtns

		getSelectedOutcomes: ->
			do @_viewModel.getSelectedOutcomes

		dispose: ->
			do @_viewModel?.dispose
			do @_betoffer?.dispose
			@_viewModel = undefined
			@_betoffer = undefined
			@renderDeferred = undefined

		#----------------------------------------------
		# Private methods
		#----------------------------------------------
		_deferredRender: ->
			@renderDeferred.resolve @_betoffer.render().$el

		_getBetofferClass: (betofferType) ->
			BetofferView = BaseBetofferView
			switch betofferType
				when BetofferTypes.TYPE_HANDICAP then window.console.log 'create instance of handicap'
				when BetofferTypes.TYPE_1X2 then BetofferView = OneCrossTwoView
				when BetofferTypes.TYPE_RESULT then window.console.log 'create instance of result'
				when BetofferTypes.TYPE_OUTRIGHT then window.console.log 'create instance of outright'
				when BetofferTypes.TYPE_OVER_UNDER then window.console.log 'create instance of over_under'
				when BetofferTypes.TYPE_ASIAN then window.console.log 'create instance of asian'
				when BetofferTypes.TYPE_HT_FT then window.console.log 'create instance of ht_ft'
				when BetofferTypes.TYPE_SIDE_BETS then window.console.log 'create instance of side_bets'
				when BetofferTypes.TYPE_ODD_EVEN then window.console.log 'create instance of odd_even'
				when BetofferTypes.TYPE_THREE_WAY_HCP then window.console.log 'create instance of three_way_handicap'
				when BetofferTypes.TYPE_DOUBLE_CHANCE then window.console.log 'create instance of double_chance'
				when BetofferTypes.TYPE_HEAD then window.console.log 'create instance of head'
				when BetofferTypes.TYPE_GOALSCORER then window.console.log 'create instance of goalscorer'
				when BetofferTypes.TYPE_SCORECAST then window.console.log 'create instance of scorecast'
				when BetofferTypes.TYPE_SCORER then window.console.log 'create instance of scorer'
				when BetofferTypes.TYPE_YES_NO then window.console.log 'create instance of yes_no'
				when BetofferTypes.TYPE_MULTI_POSITION then window.console.log 'create instance of multi_position'
				when BetofferTypes.TYPE_WINCAST then window.console.log 'create instance of wincast'
				else
					new Error 'Unrecognized betoffer type'

			return BetofferView

		_onViewModelDataLoaded: (betofferViewModel) =>
			@createBetoffer betofferViewModel.toJSON()
			do @_deferredRender

		NAME: 'Betoffer'
		EVENTS: BetofferEvents

	return Betoffer
