define (require) ->

	BaseListModel = require '../BaseListModel'
	ApplicationSettingsModel = require 'datacommunication/models/ApplicationSettingsModel'
	LocaleUtil = require 'utils/LocaleUtil'
	SubscriptionKeys = require 'datacommunication/SubscriptionKeys'

	class HighlightedListModel extends BaseListModel

		id: 'HighlightedListModel'

		#----------------------------------------------
		# Public methods
		#----------------------------------------------

		addSubscriptions: ->
			@subscribe SubscriptionKeys.HIGHLIGHTED_GROUPS_CHANGE, @onGroupsChange, {}
			return

		removeSubscriptions: ->
			@unsubscribe SubscriptionKeys.HIGHLIGHTED_GROUPS_CHANGE
			return

		getHeader: ->
			if ApplicationSettingsModel.inRacingMode()
				return LocaleUtil.getTranslation('startpage.racingSports')
			else
				return LocaleUtil.getTranslation('startpage.popular')

		getGroups: ->
			@groups.models
			#TODO move sorting to Producer?
			#sortAlphabetically = true
			#groups
			#EventGroupSortUtil.sortLeafEventGroups(groups, sortAlphabetically)

		#----------------------------------------------
		# Private methods
		#----------------------------------------------

		#----------------------------------------------
		# Callback methods
		#----------------------------------------------

	return HighlightedListModel