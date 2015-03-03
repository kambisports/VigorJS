define (require) ->

	BaseListViewModel = require '../BaseListViewModel'
	LocaleUtil = require 'utils/LocaleUtil'
	SubscriptionKeys = require 'datacommunication/SubscriptionKeys'

	class SportsListViewModel extends BaseListViewModel

		id: 'SportsListViewModel'

		#----------------------------------------------
		# Public methods
		#----------------------------------------------

		addSubscriptions: ->
			if @sortingMethod is 'alphabetical'
				@subscribe SubscriptionKeys.SPORTS_ATOZ_GROUPS, @onGroupsChange, {}
			else
				@subscribe SubscriptionKeys.SPORTS_GROUPS, @onGroupsChange, {}
			return

		removeSubscriptions: ->
			if @sortingMethod is 'alphabetical'
				@unsubscribe SubscriptionKeys.SPORTS_ATOZ_GROUPS
			else
				@unsubscribe SubscriptionKeys.SPORTS_GROUPS
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

	return SportsListViewModel
