define (require) ->

	ApiService = require 'datacommunication/apiservices/ApiService'
	GroupsRepository = require 'datacommunication/repositories/groups/GroupsRepository'
	LocalStorage = require 'datacommunication/repositories/localstorage/LocalStorageRepository'

	class GroupsHighlightedService extends ApiService

		prefetchDataKey: 'prefetchedHighlight'

		constructor: (GroupsRepository) ->
			pollInterval = 1000 * 15
			super GroupsRepository, pollInterval

		parse: (response) ->
			super response
			@repository.set @_decorateGroups(response.groups), { remove: false }

		_decorateGroups: (groups) ->
			for group in groups
				group.highlighted = true
			return groups

		NAME: 'GroupsHighlightedService'

	return new GroupsHighlightedService GroupsRepository