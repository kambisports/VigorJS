define (require) ->

	BaseListModel = require './BaseListModel'
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