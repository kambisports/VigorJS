define (require) ->

	ApiService = require 'datacommunication/apiservices/ApiService'
	LocalStorage = require 'datacommunication/repositories/localstorage/LocalStorageRepository'

	class GroupsHighlightedService extends ApiService

		prefetchDataKey: 'prefetchedHighlight'

		constructor: () ->
			pollInterval = 1000 * 30
			super pollInterval

		run: (options) ->
			do @startPolling

		parse: (response) ->
			super response
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

		NAME: 'GroupsHighlightedService'
		GROUPS_HIGHLIGHTED_RECEIVED: 'highlighted-groups-received'

	return new GroupsHighlightedService()