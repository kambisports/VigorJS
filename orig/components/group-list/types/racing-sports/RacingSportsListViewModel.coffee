define (require) ->

	BaseListViewModel = require '../BaseListViewModel'
	LocaleUtil = require 'utils/LocaleUtil'
	SubscriptionKeys = require 'datacommunication/SubscriptionKeys'

	class RacingSportsListViewModel extends BaseListViewModel

		id: 'RacingSportsListViewModel'

		#----------------------------------------------
		# Public methods
		#----------------------------------------------

		addSubscriptions: ->
			@subscribe SubscriptionKeys.SPORTS_GROUPS, @onGroupsChange, {}
			return

		removeSubscriptions: ->
			@unsubscribe SubscriptionKeys.SPORTS_GROUPS
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

	return RacingSportsListViewModel