define (require) ->

	Backbone = require 'lib/backbone'
	ViewModel = require 'common/ViewModel'
	SubscriptionKeys = require 'datacommunication/SubscriptionKeys'

	# ----------------------------------------------------------------------------------------------------
	class BrowseHighlightedViewModel extends ViewModel

		TRACKING_PREFIX = 'Featured'

		itemsCollection: undefined
		id: 'BrowseHighlightedViewModel'
		titleTranslationKey: 'startpage.popular'

		# ------------------------------------------------------------------------------------------------

		constructor: ->
			@itemsCollection = new Backbone.Collection()
			super

		addSubscriptions: ->
			@subscribe SubscriptionKeys.HIGHLIGHTED_GROUPS, @_onNewGroups, {}

		removeSubscriptions: ->
			@unsubscribe SubscriptionKeys.HIGHLIGHTED_GROUPS

		# ------------------------------------------------------------------------------------------------
		_decorateData: (highlightedGroups) ->
			for group in highlightedGroups
				group.trackingSignature = "#{TRACKING_PREFIX} - #{group.groupPath}"
				group.title = group.localizedGroupPath

			return highlightedGroups

		_storeData: (highlightedGroups) ->
			@itemsCollection.reset @_decorateData(highlightedGroups)

		_onNewGroups: (highlightedGroups) =>
			@_storeData highlightedGroups

	BrowseHighlightedViewModel
