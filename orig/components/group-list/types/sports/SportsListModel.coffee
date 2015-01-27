define (require) ->

	BaseListModel = require '../BaseListModel'
	LocaleUtil = require 'utils/LocaleUtil'
	SubscriptionKeys = require 'datacommunication/SubscriptionKeys'

	class SportsListModel extends BaseListModel

		id: 'SportsListModel'

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
			if @sortingMethod is 'highlighted-first'
				return LocaleUtil.getTranslation('startpage.atoz')
			else
				return LocaleUtil.getTranslation('azSportsPage.heading')

		getGroups: ->
			@groups.models

		#----------------------------------------------
		# Protected methods
		#----------------------------------------------

		#----------------------------------------------
		# Private methods
		#----------------------------------------------
		
		#----------------------------------------------
		# Callback methods
		#----------------------------------------------
		
	return SportsListModel