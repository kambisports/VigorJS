define (require) ->

	BaseListModel = require '../BaseListModel'
	LocaleUtil = require 'utils/LocaleUtil'
	SubscriptionKeys = require 'datacommunication/SubscriptionKeys'

	class RacingSportsListModel extends BaseListModel

		id: 'RacingSportsListModel'

		#----------------------------------------------
		# Public methods
		#----------------------------------------------

		addSubscriptions: ->
			@subscribe SubscriptionKeys.SPORTS_GROUPS_CHANGE, @onGroupsChange, {}
			return

		removeSubscriptions: ->
			@unsubscribe SubscriptionKeys.SPORTS_GROUPS_CHANGE
			return

		getHeader: ->
			LocaleUtil.getTranslation('startpage.racingSports')

		getGroups: ->
			@groups.models

		#----------------------------------------------
		# Private methods
		#----------------------------------------------

		#----------------------------------------------
		# Callback methods
		#----------------------------------------------

	return RacingSportsListModel