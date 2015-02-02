define (require) ->

	Backbone = require 'lib/backbone'
	ViewModel = require 'common/ViewModel'
	SubscriptionKeys = require 'datacommunication/SubscriptionKeys'

	# Re-written in CS - vicweb - 10/12/2014
	# ----------------------------------------------------------------------------------------------------
	class BrowseHighlightedViewModel extends ViewModel

		highlightedGroupsCollection: undefined
		id: 'BrowseHighlightedViewModel'
		titleTranslationKey: 'startpage.popular'

		# ------------------------------------------------------------------------------------------------

		constructor: ->
			@highlightedGroupsCollection = new Backbone.Collection()
			super

		addSubscriptions: ->
			@subscribe SubscriptionKeys.HIGHLIGHTED_GROUPS, @_onNewGroups, {}
		# ------------------------------------------------------------------------------------------------

		# ------------------------------------------------------------------------------------------------
		_storeData: (highlightedGroups) =>
			@highlightedGroupsCollection.reset highlightedGroups
		# ------------------------------------------------------------------------------------------------

		_onNewGroups: (groups) =>
			@highlightedGroupsCollection.reset groups

	BrowseHighlightedViewModel
