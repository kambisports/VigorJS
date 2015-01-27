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

		queryGroups: ->
			@models

		querySportsGroups: ->
			@getChildGroupsById 1

		###
		queryGroupById: (id) ->
			deferred = Q.defer()
			console.log '@getGroupById id', id, @getGroupById id
			if @isEmpty()
				@listenToOnce @, 'add', ->
					deferred.resolve @getGroupById id

				@trigger GroupsRepository::POLL_ONCE_GROUPS
			else
				deferred.resolve @getGroupById id

			return deferred.promise
		###

		queryHighlightedGroups: ->
			groups = @_getHighlightedGroups() or []
			
			#groups
			@sortLeafEventGroups groups, false


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

		# Returns an array of group ids of all siblings to the group
		# with specified id.
		getSiblingsToGroup: (id) ->
			siblings = []
			parentId = @getGroupById(id)?.get('parentId')
			_.each @models, (group) ->
				if group.get('parentId') is parentId
					siblings.push group.get('id')

			siblings

		getSubGroups: (id) ->
			[]

		getLeafEventGroups: (id) ->
			leafEventGroups = []

			_.each @models, (group) =>
				groupId = group.get('id')
				isChild = @_isEventGroupChildOf groupId, id
				if isChild
					isLeaf = @_isLeafGroup groupId
					if isLeaf then leafEventGroups.push group

			leafEventGroups

		sortLeafEventGroups: (groups, sortAlphabetically) ->
			result = if groups then groups.concat() else []

			result.sort _.bind (a, b) ->
				aSortOrder = @_getBranchHighlightedSortOrder(a)
				bSortOrder = @_getBranchHighlightedSortOrder(b)
				aSortOrderValid = @_isValidSortOrder(aSortOrder)
				bSortOrderValid = @_isValidSortOrder(bSortOrder)
				aIsHighlighted = @_getHighlightData(a).highlighted
				bIsHighlighted = @_getHighlightData(b).highlighted
				isInHighlighted = aSortOrderValid or bSortOrderValid or aIsHighlighted or bIsHighlighted

				console.log 'aSortOrder', aSortOrder, a.get('name')

				# check highlighted sort order
				if not sortAlphabetically and isInHighlighted
					# sort by highlighted
					if aSortOrderValid and not bSortOrderValid
						# sort b after a
						return -1
					else if not aSortOrderValid and bSortOrderValid
						# sort a after b
						return 1
					else if aSortOrderValid and bSortOrderValid
						# both has highlighted sort order

						# both has the same HL sort Order (siblings)
						if aSortOrder is bSortOrder
							# check if only one of the groups is highlighted
							if aIsHighlighted and not bIsHighlighted
								# sort b after a
								return -1
							else if not aIsHighlighted and bIsHighlighted
								# sort a after b
								return 1
						else
							return aSortOrder - bSortOrder
					else
						# none has sortOrder

						# check if only one of the groups is highlighted
						if aIsHighlighted and not bIsHighlighted
							# sort b after a
							return -1
						else if not aIsHighlighted and bIsHighlighted
							# sort a after b
							return 1

				aLevel = a.get('level')
				bLevel = b.get('level')

				# special case when group contains subgroups of different level
				if aLevel isnt bLevel
					if aLevel > bLevel
						return 1
					else
						return -1

				# if highlighted sort order is the same, we continue with standard sorting
				groupsToSort = @_getGroupsToSort(a, b)
				a = groupsToSort[0]
				b = groupsToSort[1]
				aSortOrder = a.get('sortOrder')
				bSortOrder = b.get('sortOrder')
				aHasSortOrder = a.hasSortOrder()
				bHasSortOrder = b.hasSortOrder()
				hasSortOrder = aHasSortOrder or bHasSortOrder
				level = a.get('level')

				# sort alphabetically if no sortOrder or if level is 2 (country level)
				isSortAlphabetically = sortAlphabetically is true
				isLevel2 = level is 2
				if not hasSortOrder or (isSortAlphabetically and isLevel2)
					if a.get('name').toLowerCase() > b.get('name').toLowerCase()
						return 1
					else if a.get('name').toLowerCase() < b.get('name').toLowerCase()
						return -1
					return 0

				else if not aHasSortOrder and bHasSortOrder
					# sort a after b
					return 1
				else if aHasSortOrder and not bHasSortOrder
					# sort b after a
					return -1
				else
					# sort on sortOrder
					return ((+aSortOrder) - (+bSortOrder))
			, this #scope

			result

		###
		Returns highest highlighted sortOrder (Number) for specified group
		or its parent group.
		###
		_getBranchHighlightedSortOrder: (group) ->
			sortOrder = undefined
			leafEventGroup = group
			updateSortOrder = (what) =>
				highlightedSortOrder = @_getHighlightData(what).highlightedSortOrder
				if @_isValidSortOrder(highlightedSortOrder)
					if not @_isValidSortOrder(sortOrder) or +highlightedSortOrder < sortOrder
						sortOrder = +highlightedSortOrder

			if group
				updateSortOrder(group)
				updateSortOrder(@getGroupById(group.get('parentId')))

			# check sibling event groups
			if not @_isValidSortOrder(sortOrder)
				siblings = @_getSiblingsToEventGroupById(leafEventGroup.get('id'))
				_.each siblings, (siblingId) =>
					sibling = @getGroupById(siblingId)
					updateSortOrder(sibling)

			sortOrder

		_isValidSortOrder: (sortOrderString) ->
			not _.isNaN(parseInt(sortOrderString, 10))

		###
		Returns the groups to sort on
		Based on closest common parent group, or if groups are
		in highlighted list.
		###
		_getGroupsToSort: (a, b) ->
			ccEG = @_getClosestCommonParentGroup(a, b)
			ccId = if ccEG then ccEG.get('id') else undefined

			# get the groups inside the closest common parent group
			while a.get('parentId') isnt ccId
				aParentGroup = @getGroupById(a.get('parentId'))
				if not aParentGroup
					break
				a = aParentGroup

			while b.get('parentId') isnt ccId
				bParentGroup = @getGroupById(b.get('parentId'))
				if not bParentGroup
					break
				b = bParentGroup
			return [a, b]

		_getSiblingsToEventGroupById: (id) ->
			group = @getGroupById id
			# Featured resource can incorrectly send groups that does not
			# exist in open.json or groups.json. Then we can not do anything.
			return [] unless group

			siblings = @getSiblingsToGroup group.get('id')
			return _.without(siblings, id)

		_getClosestCommonParentGroup: (a, b) ->
			aParentId = a.get('parentId')
			bParentId = b.get('parentId')

			# check if parents are the same
			# or if ones parent is same as other self
			if aParentId is bParentId
				return @getGroupById(aParentId)
			else if aParentId is b.get('id')
				return @getGroupById(bParentId)
			else if bParentId is a.get('id')
				return @getGroupById(aParentId)

			# move to next level
			a =	 @getGroupById(aParentId)
			b =	 @getGroupById(bParentId)
			
			if a and b and aParentId isnt bParentId and aParentId isnt GroupsRepository::EVENT_GROUP_ROOT_ID and bParentId isnt GroupsRepository::EVENT_GROUP_ROOT_ID
				return @_getClosestCommonParentGroup a, b
			else
				return @getGroupById(GroupsRepository::EVENT_GROUP_ROOT_ID)

		_isLeafGroup: (id) ->
			foundChild = _.find @models, (group) ->
				return group.get('parentId') is id

			not foundChild

		_isEventGroupChildOf: (id, parentId) ->
			group = @getGroupById id

			while (group and (group.get('id')) isnt GroupsRepository::EVENT_GROUP_ROOT_ID)
				if group.get('parentId') is parentId
					return true
				group = @getGroupById group.get('parentId')

			false

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
			return @where 'highlighted': true

		_getHighlightedGroupById: (id) ->
			group = @where
				'id': id
				'highlighted': true

			return if group?.length then group[0] else undefined

		_getHighlightData: (group) ->
			if group
				highlightedGroup = @_getHighlightedGroupById group.get('id')

			if highlightedGroup
				highlighted: true
				highlightedSortOrder: highlightedGroup.get('sortOrder') or ''
			else
				highlighted: false
				highlightedSortOrder: ''

		_filterById: (idArray) ->
			return _.map idArray, (id) => return @get(id)

		POLL_ONCE_GROUPS: 'poll_once_groups'
		POLL_ONCE_HIGHLIGHTED: 'poll_once_highlighted'

		EVENT_GROUP_ROOT_ID: 1

		NAME: 'GroupsRepository'

		makeTestInstance: ->
			new GroupsRepository()

	return new GroupsRepository()