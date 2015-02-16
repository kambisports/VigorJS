define (require) ->

	GroupsRepository = require 'datacommunication/repositories/groups/GroupsRepository'

	groupDecoratorBase =

		addGroupPath: (groupJSON) ->
			reverse = true
			separator = ' / '
			skipFirst = true
			path = GroupsRepository.getGroupPathById groupJSON.id, separator, reverse, skipFirst
			groupJSON.groupPath = path
			return groupJSON

		addLocalizedGroupPath: (groupJSON) ->
			reverse = true
			separator = ' / '
			skipFirst = true
			path = GroupsRepository.getLocalizedGroupPathById groupJSON.id, separator, reverse, skipFirst
			groupJSON.localizedGroupPath = path
			return groupJSON

		addUrl: (groupJSON) ->
			groupJSON.url = "#group/#{groupJSON.id}"
			return groupJSON


	return groupDecoratorBase

