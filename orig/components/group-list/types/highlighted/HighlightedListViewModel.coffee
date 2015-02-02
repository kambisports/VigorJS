define (require) ->

	BaseListViewModel = require '../BaseListViewModel'
	ApplicationSettingsModel = require 'datacommunication/models/ApplicationSettingsModel'
	LocaleUtil = require 'utils/LocaleUtil'
	SubscriptionKeys = require 'datacommunication/SubscriptionKeys'

	class HighlightedListViewModel extends BaseListViewModel

		id: 'HighlightedListViewModel'

		#----------------------------------------------
		# Public methods
		#----------------------------------------------

		addSubscriptions: ->
			@subscribe SubscriptionKeys.HIGHLIGHTED_GROUPS, @onGroupsChange, {}
			return

		removeSubscriptions: ->
			@unsubscribe SubscriptionKeys.HIGHLIGHTED_GROUPS
			return

		getHeader: ->
			if ApplicationSettingsModel.inRacingMode()
				return LocaleUtil.getTranslation('startpage.racingSports')
			else
				return LocaleUtil.getTranslation('startpage.popular')

		getGroups: ->
			@groups.models

		#----------------------------------------------
		# Private methods
		#----------------------------------------------

		#----------------------------------------------
		# Callback methods
		#----------------------------------------------

	return HighlightedListViewModel
