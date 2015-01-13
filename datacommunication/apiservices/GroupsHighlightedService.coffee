define (require) ->

	ApiService = require 'datacommunication/apiservices/ApiService'
	GroupsRepository = require 'datacommunication/repositories/groups/GroupsRepository'
	LocalStorage = require 'datacommunication/repositories/localstorage/LocalStorageRepository'

	class GroupsHighlightedService extends ApiService

		prefetchDataKey: 'prefetchedHighlight'

		constructor: (GroupsRepository) ->
			pollInterval = 1000 * 60 * 30

			super GroupsRepository, pollInterval

		bindRepositoryListeners: ->
			super
			@service.listenTo @repository, GroupsRepository.POLL_ONCE_HIGHLIGHTED, @pollOnce


		unbindRepositoryListeners: ->
			super
			@service.stopListening @repository, GroupsRepository.POLL_ONCE_HIGHLIGHTED, @pollOnce

		parse: (response) ->
			super response
			@repository.setHighlighted response.groups


		NAME: 'GroupsHighlightedService'

	return new GroupsHighlightedService GroupsRepository