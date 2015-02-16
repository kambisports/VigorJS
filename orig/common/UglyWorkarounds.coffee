define (require) ->

	_ = require 'lib/underscore'
	AppModel = require 'model/AppModel'
	Betslip = require 'model/Betslip'
	Events = require 'model/Events'
	AppConstants = require 'AppConstants'
	CurrencyUtil = require 'utils/CurrencyUtil'
	EventBus = require 'common/EventBus'
	EventKeys = require 'datacommunication/EventKeys'

	# This file contains unresolved issues related to the facade,
	# that we do not want to polute our other files with

	class UglyWorkarounds extends View

		onRegister: ->
			@_appModel = @retrieveModel(AppModel.NAME)
			@_eventsModel = @retrieveModel(Events.NAME)
			EventBus.subscribe EventKeys.ADD_OUTCOMES_TO_BETSLIP_REQUESTED, @_onAddOutcomeToBetslipRequest
			EventBus.subscribe EventKeys.FACADE_PARSE_MOSTPOPULAR, @_onFacadeParseMostPopular

		_onFacadeParseMostPopular: (response) =>
			@sendMessage AppConstants.C_PARSE_MOST_POPULAR, response, AppConstants.FETCH_MOST_POPULAR_SUCCESS

		_onAddOutcomeToBetslipRequest: (betslipData) =>
			unless betslipData?.outcomes then return
			# THIS IS UGLY, the betslip should have a nicer way to recieve incomming outcomes
			betslipModel = this.retrieveModel(Betslip.NAME)

			for outcome in betslipData.outcomes

				betslipObj =
					stake: betslipData.stake
					outcomeId: outcome.outcomeId

				outcomeToAdd = @_eventsModel.getAddToBetslipObject(outcome.outcomeId)

				betslipModel.addOutcome outcomeToAdd, false, true

				@sendMessage AppConstants.C_ADD_STAKE_TO_BETSLIP, betslipObj
				@sendMessage AppConstants.FORCE_STAKE_TO_INPUT_FIELD, outcome.outcomeId

				@sendMessage AppConstants.C_ADD_STAKE_TO_BETSLIP,
					stake: betslipData.stake

			@sendMessage AppConstants.FORCE_STAKE_TO_INPUT_FIELD

	UglyWorkarounds.NAME = 'UglyWorkarounds'

	return UglyWorkarounds
