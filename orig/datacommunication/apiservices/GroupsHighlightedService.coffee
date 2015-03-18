define (require) ->

	KambiApiService = require 'datacommunication/apiservices/KambiApiService'
	LocalStorage = require 'datacommunication/repositories/localstorage/LocalStorageRepository'

	class GroupsHighlightedService extends KambiApiService

		prefetchDataKey: 'prefetchedHighlight'

		parse: (response) ->
			@propagateResponse @GROUPS_HIGHLIGHTED_RECEIVED, @_decorateHighlightedGroups(response.groups)

		_decorateHighlightedGroups: (groups) ->
			for group in groups
				group.highlighted = true
				# We must store sortOrder for highlighted separately, since
				# it will otherwise be overwritten when we poll groups.
				group.highlightedSortOrder = group.sortOrder

				# Delete property so that it does not owerwrite existing one.
				delete group.sortOrder
			groups

		GROUPS_HIGHLIGHTED_RECEIVED: 'highlighted-groups-received'

		urlPath: -> '/group/highlight.json'

	new GroupsHighlightedService()
