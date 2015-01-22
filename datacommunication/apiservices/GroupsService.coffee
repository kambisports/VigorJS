define (require) ->

	ApiService = require 'datacommunication/apiservices/ApiService'
	GroupsRepository = require 'datacommunication/repositories/groups/GroupsRepository'

	responseFlattener = require 'datacommunication/apiservices/utils/responseFlattener'

	class GroupsService extends ApiService

		prefetchDataKey: 'prefetchedGroup'

		constructor: (GroupsRepository) ->
			pollInterval = 1000 * 60 * 10

			super GroupsRepository, pollInterval

		bindRepositoryListeners: ->
			super
			@service.listenTo @repository, GroupsRepository.POLL_ONCE_GROUPS, @pollOnce

		unbindRepositoryListeners: ->
			super
			@service.stopListening @repository, GroupsRepository.POLL_ONCE_GROUPS, @pollOnce

		parse: (response) ->
			super
			flatGroupModels = @flattenResponse response
			GroupsRepository.set flatGroupModels

		flattenResponse: (response) ->
			groupModels = @getGroupsFromResponse response

			flatteningSpecs =

				# ModelClass - The nodes in the flattened response will be of this type. If left out, they will be simple JS key/value objects.
				# ModelClass: GroupModel

				# Options are responseFlattener.METHOD_DEPTH_FIRST (default) and responseFlattener.METHOD_BREADTH_FIRST
				flattenMethod: responseFlattener.METHOD_BREADTH_FIRST

				# The key in the response that uniquely identifies each node. The default is 'id'. If a value is provided that does not exist,
				# it will be created automatically and used both for the identifier and parentId attributes of the returned nodes.
				uniqueIdentifier: 'id'

				# The key in the response that identifies the child-nodes for this element. The default is 'groups'. A comma-seperated string
				# maybe be provided to identity several child-nodes.
				indexName: 'groups,test'

			flattenedResponse = responseFlattener.flatten groupModels, flatteningSpecs

			return flattenedResponse

		#
		# Retrieve the groups object from the response. Throws an exception
		# if not found.
		# @param {object} response The response object from the API
		# @returns {object} The groups section of the response
		#
		getGroupsFromResponse: (response) ->
			groupsExistsInResponse = response?.group and response?.group?.groups

			if not groupsExistsInResponse
				throw 'The response object does not contain the necessary groups tree structure.'
			else
				groups = response.group.groups

			return groups

		NAME: 'GroupsService'

	return new GroupsService GroupsRepository