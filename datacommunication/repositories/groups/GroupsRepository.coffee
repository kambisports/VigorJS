define (require) ->

	_ = require 'lib/underscore'
	Q = require 'lib/q'
	ServiceRepository = require 'datacommunication/repositories/ServiceRepository'
	GroupModel = require 'datacommunication/repositories/groups/GroupModel'

	class GroupsRepository extends ServiceRepository

		model: GroupModel

		_highlightedIdsArray: []

		initialize: ->
			super

		setHighlighted: (highlightedArray) ->
			@_highlightedIdsArray = _.pluck highlightedArray, (group) ->
				return group.id

			@set highlightedArray, remove: false
			@trigger 'change:highlightedGroups', highlightedArray

		queryGroups: ->
			deferred = Q.defer()
			unless @isEmpty() then deferred.resolve @models

			@trigger GroupsRepository::POLL_ONCE_GROUPS

			@listenToOnce @, 'add', ->
				deferred.resolve @models

			return deferred.promise

		queryHighlightedGroups: ->
			deferred = Q.defer()
			hasHighlightedIds = @_highlightedIdsArray.length > 0

			if hasHighlightedIds then deferred.resolve @_getHighlightedGroups()

			@trigger GroupsRepository::POLL_ONCE_HIGHLIGHTED

			@listenToOnce @, 'change:highlightedGroups', ->
				deferred.resolve @_getHighlightedGroups()

			return deferred.promise

		queryGroupById: (groupId) ->
			deferred = Q.defer()
			deferred.resolve { todoMicke: 'FIX_ME' }
			return deferred.promise

		#TODO: UNIT TEST THEESE METHODS
		getChildTreeById: (id) ->
			group = @findWhere(id: id) or {}
			groupId = group.get('id') or 1
			parentGroupObj =
				group: group
				groups: []

			tree = @_buildChildTree parentGroupObj, groupId
			return tree

		getAncestorTreeById: (id) ->
			childGroupObj =
				group: @findWhere(id: id) or {id: 'root'}

			tree = @_buildAncestorTree childGroupObj
			return tree

		getAncestorArrayById: (id) ->
			ancestorArray = @_ancestorTreeToArray @getAncestorTreeById(id), []
			return ancestorArray

		getChildGroupsById: (id) ->
			return @where 'parentId': id

		getLocalizedGroupPathById: (id, separator = ' / ', reverse = true, skipFirst = false) ->
			pathArray = @getAncestorArrayById id
			nameArray = (pathItem.get('name') for pathItem in pathArray)
			if skipFirst then do nameArray.shift
			if reverse then nameArray.reverse()
			return nameArray.join(separator)

		getGroupById: (id) ->
			return @get id

		# attaches a groups object on each model containeng each groups subgroup
		# starging with the passed parent group
		_buildChildTree: (parentGroupObj, parentId) ->
			childGroups = @getChildGroupsById parentId

			for group in childGroups
				groupObj =
					group: group
					groups: []

				parentGroupObj.groups.push groupObj

				@_buildChildTree groupObj, group.get('id')

			return parentGroupObj

		_buildAncestorTree: (childGroupObj) ->
			parent = @get childGroupObj.group.get('parentId')

			if parent
				parentObj =
					group: parent

				childGroupObj.parent = parentObj
				@_buildAncestorTree parentObj

			else
				childGroupObj.parent = 'root'

			return childGroupObj

		_ancestorTreeToArray: (tree, array) ->
			array.push tree.group
			if tree.parent and tree.parent isnt 'root'
				@_ancestorTreeToArray tree.parent, array
			return array

		_getHighlightedGroups: ->
			return @_filterById @_highlightedIdsArray

		_filterById: (idArray) ->
			return _.map idArray, (id) => return @get(id)

		POLL_ONCE_GROUPS: 'poll_once_groups'
		POLL_ONCE_HIGHLIGHTED: 'poll_once_highlighted'

		NAME: 'GroupsRepository'

		makeTestInstance: ->
			new GroupsRepository()

	return new GroupsRepository()