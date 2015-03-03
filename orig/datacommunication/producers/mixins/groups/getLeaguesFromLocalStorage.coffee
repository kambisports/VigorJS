define (require) ->

	LocalStorageRepository = require 'datacommunication/repositories/localstorage/LocalStorageRepository'
	GroupsRepository = require 'datacommunication/repositories/groups/GroupsRepository'

	getGroupsFromLocalStorage: ->
		punterSettings = LocalStorageRepository.queryPunterSettings()
		groupsFromLocalStorage = GroupsRepository.getGroupsByIds(punterSettings?.navigation?.leagues)
		groupsFromLocalStorage

