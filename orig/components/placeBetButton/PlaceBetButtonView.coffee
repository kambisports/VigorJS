define [
	'jquery'
	'AppConstants'
	'view/common/KambiBackboneView'
	'model/Betslip'
	'utils/UserSettingsUtil'
	'utils/LocaleUtil'
	'utils/StringUtil'
	'utils/TrackingUtil'
	'utils/TrackingUtilMessages'
	'lib/text!components/placeBetButton/templates/PlaceBetButtonTemplate.html!strip'
], (
	$
	AppConstants
	KambiBackboneView
	Betslip
	UserSettingsUtil
	LocaleUtil
	StringUtil
	TrackingUtil
	TrackingUtilMessages
	PlaceBetButtonTemplate
) ->


	class PlaceBetButtonView extends KambiBackboneView

		_betslipModel: undefined

		_context: undefined
		_disabled: no

		_$settingsMenu: 	undefined
		_$actionInputs: 	undefined
		_$informationBox: 	undefined
		_$confirmationLink: undefined
		_$buttonContainer: 	undefined
		_$placeButton: 		undefined
		_$openButton: 		undefined
		_$actionLabel: 		undefined


		tagName: 'div'
		className: 'component-placebetbutton__wrapper'

		template: _.template PlaceBetButtonTemplate

		events:
			'click .settings-information__confirmation': '_onConfirmationLinkClick'
			'click .placebet-container .placebet-container__open': '_onOpenMenuBtnClick'
			'click .placebet-container .placebet-container__place': '_onPlaceBetBtnClick'
			'click .settings-override__item-input' : '_onSettingItemClick'

		initialize: (attr) ->
			@model = attr.userSettingsModel
			@_betslipModel = attr.betslipModel
			@_context = attr.context or PlaceBetButtonView.CONTEXT_BETSLIP

			@model.on 'change:showOddsChangeOptions', @_updateOpenButton
			@model.on 'change:oddsChangeAction', @_updateChecked
			@model.on 'change:showConfirmationBox', @_updateInformationBox

			@_betslipModel.on Betslip.EVENT_OUTCOME_ADDED + ' ' + Betslip.EVENT_OUTCOME_REMOVED, @_onBetslipItemsChanged, @

			super


		dispose: ->
			@_betslipModel.off null, null, @

			$('body').off 'click', @_hideSettingsMenu

			@model.off 'change:showOddsChangeOptions', @_updateOpenButton
			@model.off 'change:oddsChangeAction', @_updateChecked
			@model.off 'change:showConfirmationBox', @_updateInformationBox

			@_$settingsMenu = null
			@_$actionInputs = null
			@_$informationBox = null
			@_$confirmationLink = null
			@_$buttonContainer = null
			@_$placeButton = null
			@_$openButton = null
			@_$actionLabel = null

			@_betslipModel = null

			super


		render: ->
			@$el.html @template @_getProperties()

			@_$settingsMenu = @$el.find '.settings-override'
			@_$actionInputs = @$el.find '.settings-override__item-input'

			@_$informationBox = @$el.find '.settings-information'
			@_$confirmationLink = @$el.find '.settings-information__confirmation'

			@_$buttonContainer = @$el.find '.placebet-container'
			@_$placeButton = @_$buttonContainer.find '.placebet-container__place'
			@_$openButton = @_$buttonContainer.find '.placebet-container__open'
			@_$actionLabel = @_$buttonContainer.find '.placebet-container__place-action'

			do @_bindEvents
			do @_updateOpenButton
			do @_updateButtonState

			return @


		disable: ->
			@_disabled = yes
			if @_$buttonContainer
				do @_updateButtonState


		enable: ->
			@_disabled = no
			if @_$buttonContainer
				do @_updateButtonState


		############### Handler ###############

		_onBetslipItemsChanged: =>
			# this view may have been disposed by a previous callback listening to betslip item changes
			# checking whether fields are null is the only way we can check whether this has happened
			if @_betslipModel?
				@_updateOpenButton()
				@_updateButtonLabel()


		_updateOpenButton: =>
			if @_shouldShowOddsChangeActions()
				#@_$buttonContainer.addClass 'has-options'
				@_$openButton.show()
			else
				#@_$buttonContainer.removeClass 'has-options'
				@_$openButton.hide()


		_updateInformationBox: =>
			if @model.showConfirmation() then @_$informationBox.show() else @_$informationBox.hide()


		_updateButtonState: ->
			if @_disabled
				@_$buttonContainer.addClass 'disabled'
				@_$placeButton.addClass 'placing'
				@_$openButton.addClass 'placing'
			else
				@_$buttonContainer.removeClass 'disabled'
				@_$placeButton.removeClass 'placing'
				@_$openButton.removeClass 'placing'


		_updateButtonLabel: =>
			@_$actionLabel.html @_getOddsChangeButtonLabel()


		_onPlaceBetBtnClick: (e) =>
			do e.stopPropagation
			do e.preventDefault
			if not @_disabled
				# odds change options are automatically enabled the first time punter approves odds changes
				if @_context is PlaceBetButtonView.CONTEXT_BETSLIP_ODDS_CHANGE
					do @model.initiateOddsChangeMenu

				@trigger PlaceBetButtonView.PLACE_BET,
					id: $(e.currentTarget).data 'button-id'


		_onOpenMenuBtnClick: (e) =>
			do e.stopPropagation
			if not @_disabled
				if @_$settingsMenu.is(':visible') then @_hideSettingsMenu() else @_showSettingsMenu()
				do @_updateChecked
				do @_updateInformationBox


		_onSettingItemClick: (e) =>
			do e.stopPropagation

			action = do @_getSelectedOddsChangeAction

			@model.set 'oddsChangeAction', action

			do @_hideSettingsMenu


		_onConfirmationLinkClick: (e) =>
			do e.stopPropagation
			do e.preventDefault
			@model.set 'showConfirmationBox', no

			TrackingUtil.send TrackingUtilMessages.CATEGORY_BET_REJECTION,
				TrackingUtilMessages.ACTION_BET_REJECTION_INFO_ACKNOWLEDGED


		_updateChecked: =>
			value = do @model.getOddsChangeAction

			$radio = @$("input:radio[name='settings_override'][value='" + value + "']")
			$radio.attr 'checked', 'checked' if $radio.length is 1

			@_updateButtonLabel()


		############### Private ###############

		_shouldShowOddsChangeActions: ->
			(@model.get 'showOddsChangeOptions') and @_betslipModel.hasLiveOutcomes()


		_bindEvents: ->
			$('body').on 'click', @_hideSettingsMenu


		_showSettingsMenu: ->
			do @_$settingsMenu.show
			@_$openButton.addClass 'menu-open'


		_hideSettingsMenu: =>
			do @_$settingsMenu.hide
			@_$openButton.removeClass 'menu-open'


		_getSelectedOddsChangeAction: ->
			@$("input:radio[name='settings_override']:checked").val()


		_getPlaceBetLabel: ->
			switch @_context
				when PlaceBetButtonView.CONTEXT_BETSLIP
					LocaleUtil.getTranslation 'betslip.placebetbutton.text.place'
				when PlaceBetButtonView.CONTEXT_BETSLIP_ODDS_CHANGE
					LocaleUtil.getTranslation 'betslip.placebetbutton.text.approve'
				else LocaleUtil.getTranslation 'betslip.placebetbutton.text.place'


		_getProperties: ->
			properties =
				title: 				LocaleUtil.getTranslation 'betslip.oddschange.title'
				informationLabel: 	LocaleUtil.getTranslation 'betslip.oddschange.information.text'
				confirmationLabel: 	LocaleUtil.getTranslation 'betslip.oddschange.information.accept'
				defaultLabel: 		LocaleUtil.getTranslation 'settings.oddschange.default'
				placeBetLabel: 		StringUtil.toUpperCase @_getPlaceBetLabel()
				actionLabel: 		@_getOddsChangeButtonLabel()
				options: 			@_getOptions()
				id:					@_context + '-' + Math.round(Math.random() * 1000000)


		_getOptions: ->
			options = do UserSettingsUtil.getOddsChangeOptions

			defaultOption = do UserSettingsUtil.getDefaultOption

			_.map options, (option) ->
				item =
					value: option
					label: UserSettingsUtil.getOptionLabel option
					isDefault: option is defaultOption


		_getOddsChangeButtonLabel: ->
			switch @_shouldShowOddsChangeActions()
				when true then UserSettingsUtil.getActionLabel @model.getOddsChangeAction()
				else ''


		@CONTEXT_BETSLIP = 'contextBetslip'
		@CONTEXT_BETSLIP_ODDS_CHANGE = 'contextBetslipOddsChange'

		@PLACE_BET = 'placeBet'