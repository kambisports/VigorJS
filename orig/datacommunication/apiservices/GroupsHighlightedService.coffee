define (require) ->

	ApiService = require 'datacommunication/apiservices/ApiService'
	GroupsRepository = require 'datacommunication/repositories/groups/GroupsRepository'
	LocalStorage = require 'datacommunication/repositories/localstorage/LocalStorageRepository'

	class GroupsHighlightedService extends ApiService

		prefetchDataKey: 'prefetchedHighlight'

		constructor: (GroupsRepository) ->
			pollInterval = 1000 * 30
			super GroupsRepository, pollInterval

		parse: (response) ->
			super response
			@repository.set @_decorateHighlightedGroups(response.groups), { remove: false }

			# Remove highlighted flag from existing model
			# if not in response.
			@repository.undecorateHighlightedGroupsNotInList response.groups

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

	return new GroupsHighlightedService GroupsRepository