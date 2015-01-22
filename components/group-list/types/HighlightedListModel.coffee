define (require) ->

	BaseListModel = require './BaseListModel'
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

		#----------------------------------------------
		# Protected methods
		#----------------------------------------------

		#----------------------------------------------
		# Private methods
		#----------------------------------------------

		#----------------------------------------------
		# Callback methods
		#----------------------------------------------

	return HighlightedListModel