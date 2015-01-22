define [
	'AppConstants',
	'model/UserSettingsModel'
	'model/Betslip'
	'components/placeBetButton/PlaceBetButtonView'
], (
	AppConstants
	UserSettingsModel
	BetslipModel
	PlaceBetButtonView
) ->

	"use strict"

	describe 'PlaceBetButtonView View specification', ->

		userSettingsModel = undefined
		betslipModel = undefined
		placeBetButtonView = undefined


		beforeEach ->
			betslipModel = _.extend {
				hasLiveOutcomes: ->
			}, Backbone.Events
			userSettingsModel = do UserSettingsModel.makeInstance

			placeBetButtonView = new PlaceBetButtonView
				userSettingsModel: userSettingsModel
				betslipModel: betslipModel
				context: PlaceBetButtonView.CONTEXT_BETSLIP


		renderView = (hasLiveOutcomes) ->
			spyOn(betslipModel, 'hasLiveOutcomes').andReturn hasLiveOutcomes

			do placeBetButtonView.render


		describe 'Should update the view when user settings change', ->

			it ' - oddsChangeMenu visibility with live event', ->
				renderView true

				expect(placeBetButtonView._$openButton.css 'display').toBe 'none'

				userSettingsModel.set 'showOddsChangeOptions', yes

				expect(placeBetButtonView._$openButton.css 'display').not.toBe 'none'


			it ' - oddsChangeAction visibility with live event', ->
				renderView true

				userSettingsModel.set 'showOddsChangeOptions', yes

				expect(placeBetButtonView._$actionLabel.html()).toBe ''

				userSettingsModel.set 'settingsOddsChangeAction', AppConstants.ODDS_CHANGE_APPROVE

				expect(placeBetButtonView._$actionLabel.html()).not.toBe ''


			it ' - oddsChangeMenu visibility without live event', ->
				renderView false

				expect(placeBetButtonView._$openButton.css 'display').toBe 'none'

				userSettingsModel.set 'showOddsChangeOptions', yes

				expect(placeBetButtonView._$openButton.css 'display').toBe 'none'

		describe 'should update the view when the betslip items change', ->

			it 'does not show odds change menu when no live events are present', ->

				renderView false

				userSettingsModel.set 'settingsOddsChangeAction', AppConstants.ODDS_CHANGE_APPROVE
				userSettingsModel.set 'showOddsChangeOptions', yes

				betslipModel.hasLiveOutcomes.andReturn true

				expect(placeBetButtonView._$openButton.css 'display').toBe 'none'
				expect(placeBetButtonView._$actionLabel.html()).toBe ''

				betslipModel.trigger BetslipModel.EVENT_OUTCOME_ADDED

				expect(placeBetButtonView._$openButton.css 'display').not.toBe 'none'
				expect(placeBetButtonView._$actionLabel.html()).not.toBe ''

			it 'does show odds change menu when live events are present', ->

				renderView false

				userSettingsModel.set 'settingsOddsChangeAction', AppConstants.ODDS_CHANGE_APPROVE
				userSettingsModel.set 'showOddsChangeOptions', yes

				expect(placeBetButtonView._$openButton.css 'display').toBe 'none'
				expect(placeBetButtonView._$actionLabel.html()).toBe ''

				betslipModel.trigger BetslipModel.EVENT_OUTCOME_ADDED

				expect(placeBetButtonView._$openButton.css 'display').toBe 'none'
				expect(placeBetButtonView._$actionLabel.html()).toBe ''

			it 'does not show odds change menu when live events are removed', ->

				renderView true

				userSettingsModel.set 'settingsOddsChangeAction', AppConstants.ODDS_CHANGE_APPROVE
				userSettingsModel.set 'showOddsChangeOptions', yes

				betslipModel.trigger BetslipModel.EVENT_OUTCOME_REMOVED

				expect(placeBetButtonView._$openButton.css 'display').not.toBe 'none'
				expect(placeBetButtonView._$actionLabel.html()).not.toBe ''

				betslipModel.hasLiveOutcomes.andReturn false
				betslipModel.trigger BetslipModel.EVENT_OUTCOME_REMOVED

				expect(placeBetButtonView._$openButton.css 'display').toBe 'none'
				expect(placeBetButtonView._$actionLabel.html()).toBe ''
