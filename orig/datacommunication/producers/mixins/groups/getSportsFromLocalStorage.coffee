define (require) ->

	LocalStorageRepository = require 'datacommunication/repositories/localstorage/LocalStorageRepository'
	GroupsRepository = require 'datacommunication/repositories/groups/GroupsRepository'

	getSportsFromLocalStorage: ->
		punterSettings = LocalStorageRepository.queryPunterSettings()
		sportFromLocalStorage = GroupsRepository.getGroupsByIds(punterSettings?.navigation?.sports)
		sportFromLocalStorage

