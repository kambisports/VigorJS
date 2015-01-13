define (require) ->

	Backbone = require 'lib/backbone'
	ViewModel = require 'common/ViewModel'
	QueryKeys = require 'datacommunication/QueryKeys'
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

		getHighlighedGroups: ->
			queryKey = QueryKeys.HIGHLIGHTED_GROUPS
			subscriptionKey = SubscriptionKeys.HIGHLIGHTED_GROUPS_CHANGE
			emptyObj = {}
			promise = @queryAndSubscribe queryKey,
				emptyObj,
				subscriptionKey,
				@_onHighlighedGroupsChange,
				emptyObj

			promise.then @_storeData
		# ------------------------------------------------------------------------------------------------



		# ------------------------------------------------------------------------------------------------
		_storeData: (highlightedGroups) =>
			@highlightedGroupsCollection.reset highlightedGroups
		# ------------------------------------------------------------------------------------------------

		_onHighlighedGroupsChange: (highlightedGroups) =>
			@highlightedGroupsCollection.reset highlightedGroups

	BrowseHighlightedViewModel
