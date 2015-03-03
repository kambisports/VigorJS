define (require) ->

	_ = require 'lib/underscore'
	GroupsRepository = require 'datacommunication/repositories/groups/GroupsRepository'
	responseFlattener = require 'datacommunication/apiservices/utils/responseFlattener'

	describe 'GroupsRepository', ->

		repository = undefined

		regularGroupsDataParser = (simulatedJson) ->
			groupData = JSON.parse JSON.stringify simulatedJson

			flatteningSpecs =
				flattenMethod: responseFlattener.METHOD_BREADTH_FIRST
				uniqueIdentifier: 'id'
				indexName: 'groups'
				startLevel: 1

			groupModels = groupData.group.groups
			flatGroups = responseFlattener.flatten groupModels, flatteningSpecs

		highlightedGroupsDataParser = (simulatedJson) ->
			groupData = JSON.parse JSON.stringify simulatedJson
			groups = groupData.groups
			for group in groups
				group.highlighted = true

				group.highlightedSortOrder = group.sortOrder
				delete group.sortOrder

			groups

		spawnGroupData = ->
			simulatedJSON = require './Groups-Data'
			regularGroupsDataParser simulatedJSON

		spawnAlphabeticalGroupData = ->
			simulatedJSON = require './GroupAlphabetical-Data'
			regularGroupsDataParser simulatedJSON

		spawnGroupHighlightSort1 = ->
			simulatedJSON = require './GroupHighlightSort1-Data'
			highlightedGroupsDataParser simulatedJSON

		spawnGroupHighlightSort2 = ->
			simulatedJSON = require './GroupHighlightSort2-Data'
			highlightedGroupsDataParser simulatedJSON

		spawnHighlightDecorate1 = ->
			simulatedJSON = require './GroupHighlightDecorate1-Data'
			highlightedGroupsDataParser simulatedJSON

		spawnHighlightDecorate2 = ->
			simulatedJSON = require './GroupHighlightDecorate2-Data'
			highlightedGroupsDataParser simulatedJSON

		beforeEach ->
			repository = new GroupsRepository.constructor()

		describe 'sortLeafGroups', ->

			beforeEach ->
				repository.reset()

			it '(one group) sorts a list of event group models according to event group tree', ->
				flatGroups = do spawnGroupData
				repository._onGroupsReceived flatGroups

				groups = repository.getLeafGroups 1000461733
				groups = repository.sortLeafGroups groups

				expect(groups.length).toBe(8)
				expect(groups[0].get('id')).toBe(1000094985)
				expect(groups[1].get('id')).toBe(1000094981)
				expect(groups[2].get('id')).toBe(1000094982)
				expect(groups[3].get('id')).toBe(1000094987)
				expect(groups[4].get('id')).toBe(1000095636)
				expect(groups[5].get('id')).toBe(1000095348)
				expect(groups[6].get('id')).toBe(10000951379)
				expect(groups[7].get('id')).toBe(1000095137)


			it '(one sport) sorts a list of event group models according to event group tree', ->
				flatGroups = do spawnGroupData
				repository._onGroupsReceived flatGroups

				# Ice Hochey
				groups = repository.getLeafGroups 1000093191
				groups = repository.sortLeafGroups groups

				expect(groups.length).toBe(16)

				expect(groups[0].get('id')).toBe(1000096862) # NHL / Season Bets
				expect(groups[1].get('id')).toBe(1000095686) # Finland / Seson Bets
				expect(groups[2].get('id')).toBe(1000094968) # Sweden / Elitserien
				expect(groups[3].get('id')).toBe(1000094598) # Sweden / Hockeyallsvenskan
				expect(groups[4].get('id')).toBe(1000095498) # Sweden / Season Bets
				expect(groups[5].get('id')).toBe(1000437981) # KHL / Regular Season
				expect(groups[6].get('id')).toBe(1000437982) # KHL / Season Bets
				expect(groups[7].get('id')).toBe(1000094967) # Norway / Get League
				expect(groups[8].get('id')).toBe(100019700599) # Switzerland / Sorted Base Bets
				expect(groups[9].get('id')).toBe(10001970059) # Switzerland / Base Bets
				expect(groups[10].get('id')).toBe(1000094972) # Switzerland / NLA
				expect(groups[11].get('id')).toBe(1000197005) # Switzerland / Season Bets
				expect(groups[12].get('id')).toBe(1000193541) # Germany / Season Bets
				expect(groups[13].get('id')).toBe(2000050364) # World Championship / Tournament Bets
				expect(groups[14].get('id')).toBe(1000095468) # Austria / Season Bets
				expect(groups[15].get('id')).toBe(1000435874) # Club Friendlies / Matches

			it '(alphabetically test 1) sorts a list of event group models alphabetically', ->
				flatGroups = do spawnGroupData
				repository._onGroupsReceived flatGroups

				# Alphabetically: Ice Hochey
				groups = repository.getLeafGroups 1000093191
				groups = repository.sortLeafGroups groups, true

				expect(groups.length).toBe(16)

				expect(groups[0].get('id')).toBe(1000095468) # Austria / Season Bets
				expect(groups[1].get('id')).toBe(1000435874) # Club Friendlies / Matches
				expect(groups[2].get('id')).toBe(1000095686) # Finland / Seson Bets
				expect(groups[3].get('id')).toBe(1000193541) # Germany / Season Bets
				expect(groups[4].get('id')).toBe(1000437981) # KHL / Regular Season
				expect(groups[5].get('id')).toBe(1000437982) # KHL / Season Bets
				expect(groups[6].get('id')).toBe(1000096862) # NHL / Season Bets
				expect(groups[7].get('id')).toBe(1000094967) # Norway / Get League
				expect(groups[8].get('id')).toBe(1000094968) # Sweden / Elitserien
				expect(groups[9].get('id')).toBe(1000094598) # Sweden / Hockeyallsvenskan
				expect(groups[10].get('id')).toBe(1000095498) # Sweden / Season Bets
				expect(groups[11].get('id')).toBe(100019700599) # Switzerland / Sorted Base Bets
				expect(groups[12].get('id')).toBe(10001970059) # Switzerland / Base Bets
				expect(groups[13].get('id')).toBe(1000094972) # Switzerland / NLA
				expect(groups[14].get('id')).toBe(1000197005) # Switzerland / Season Bets
				expect(groups[15].get('id')).toBe(2000050364) # World Championship / Tournament Bets

			it '(alphabetically test 2) sorts a list of event group models alphabetically', ->
				flatGroups = do spawnAlphabeticalGroupData
				repository._onGroupsReceived flatGroups

				groups = repository.getLeafGroups 1000093191
				groups = repository.sortLeafGroups groups, true

				expect(groups.length).toBe(17)

				expect(groups[0].get('id')).toBe(1000095468) # Austria / Season Bets
				expect(groups[1].get('id')).toBe(1000435874) # Club Friendlies / Matches
				expect(groups[2].get('id')).toBe(1000095686) # Finland / Seson Bets
				expect(groups[3].get('id')).toBe(1000193541) # Germany / Season Bets
				expect(groups[4].get('id')).toBe(1000437981) # KHL / Regular Season
				expect(groups[5].get('id')).toBe(1000437982) # KHL / Season Bets
				expect(groups[6].get('id')).toBe(1000096862) # NHL / Season Bets
				expect(groups[7].get('id')).toBe(1000094967) # Norway / Get League
				expect(groups[8].get('id')).toBe(1000094598) # Sweden / Hockeyallsvenskan
				expect(groups[9].get('id')).toBe(1000095498) # Sweden / Season Bets
				expect(groups[10].get('id')).toBe(1000094968) # Sweden / Elitserien
				expect(groups[11].get('id')).toBe(100019700599) # Switzerland / Sorted Bets
				expect(groups[12].get('id')).toBe(1000197005999) # Switzerland / Sorted Bets 2
				expect(groups[13].get('id')).toBe(1000094972) # Switzerland / NLA
				expect(groups[14].get('id')).toBe(10001970059) # Switzerland / Base Bets
				expect(groups[15].get('id')).toBe(1000197005) # Switzerland / Season Bets
				expect(groups[16].get('id')).toBe(2000050364) # World Championship / Tournament Bets

			it '(highlighted test 1) sorts a list of event group models according to highlighted sort order', ->
				flatGroups = do spawnGroupData
				repository._onGroupsReceived flatGroups

				highlightGroupsSort1 = do spawnGroupHighlightSort1
				repository._onGroupsHighlighedReceived highlightGroupsSort1

				groups = repository.getLeafGroups 1000093191
				groups = repository.sortLeafGroups groups

				expect(groups.length).toBe(16)

				expect(groups[0].get('id')).toBe(100019700599) # Switzerland / Sorted Base Bets
				expect(groups[1].get('id')).toBe(10001970059) # Switzerland / Base Bets
				expect(groups[2].get('id')).toBe(1000094972) # Switzerland / NLA
				expect(groups[3].get('id')).toBe(1000197005) # Switzerland / Season Bets
				expect(groups[4].get('id')).toBe(1000094598) # Sweden / Hockeyallsvenskan
				expect(groups[5].get('id')).toBe(1000094968) # Sweden / Elitserien
				expect(groups[6].get('id')).toBe(1000095498) # Sweden / Season Bets
				expect(groups[7].get('id')).toBe(1000095468) # Austria / Season Bets A
				expect(groups[8].get('id')).toBe(1000096862) # NHL / Season Bets
				expect(groups[9].get('id')).toBe(1000095686) # Finland / Seson Bets
				expect(groups[10].get('id')).toBe(1000437981) # KHL / Regular Season
				expect(groups[11].get('id')).toBe(1000437982) # KHL / Season Bets
				expect(groups[12].get('id')).toBe(1000094967) # Norway / Get League
				expect(groups[13].get('id')).toBe(1000193541) # Germany / Season Bets
				expect(groups[14].get('id')).toBe(2000050364) # World Championship / Tournament Bets
				expect(groups[15].get('id')).toBe(1000435874) # Club Friendlies / Matches


			it '(highlighted test 2) sorts a list of event group models according to highlighted sort order', ->
				flatGroups = do spawnGroupData
				repository._onGroupsReceived flatGroups

				highlightGroupsSort2 = do spawnGroupHighlightSort2
				repository._onGroupsHighlighedReceived highlightGroupsSort2

				groups = repository.getLeafGroups 1000093191
				groups = repository.sortLeafGroups groups

				expect(groups.length).toBe(16)

				expect(groups[0].get('id')).toBe(1000094967) # Norway / Get League
				expect(groups[1].get('id')).toBe(1000197005) # Switzerland / Season Bets
				expect(groups[2].get('id')).toBe(10001970059) # Switzerland / Base Bets
				expect(groups[3].get('id')).toBe(100019700599) # Switzerland / Sorted Base Bets
				expect(groups[4].get('id')).toBe(1000094972) # Switzerland / NLA
				expect(groups[5].get('id')).toBe(1000094968) # Sweden / Elitserien
				expect(groups[6].get('id')).toBe(1000094598) # Sweden / Hockeyallsvenskan
				expect(groups[7].get('id')).toBe(1000095498) # Sweden / Season Bets
				expect(groups[8].get('id')).toBe(1000437981) # KHL / Regular Season
				expect(groups[9].get('id')).toBe(1000437982) # KHL / Season Bets
				expect(groups[10].get('id')).toBe(1000096862) # NHL / Season Bets
				expect(groups[11].get('id')).toBe(1000095686) # Finland / Seson Bets
				expect(groups[12].get('id')).toBe(1000193541) # Germany / Season Bets
				expect(groups[13].get('id')).toBe(2000050364) # World Championship / Tournament Bets
				expect(groups[14].get('id')).toBe(1000095468) # Austria / Season Bets
				expect(groups[15].get('id')).toBe(1000435874) # Club Friendlies / Matches


		describe 'getClosestCommonParentGroup', ->

			beforeEach ->
				repository.reset()

				flatGroups = do spawnGroupData
				repository._onGroupsReceived flatGroups

			it 'returns the closest common parent group', ->

				# --- Test 1 ---
				# Ice Hockey / Sweden / Hockeyallsvenskan
				gA = repository.getGroupById(1000094598)
				# Ice Hockey / Club Friendlies / Matches
				gB = repository.getGroupById(1000435874)

				group = repository.getClosestCommonParentGroup(gA, gB)
				# Ice Hockey
				expect(group.get('id')).toBe(1000093191)

				# --- Test 2 ---
				# Ice Hockey / Switzerland / Base Bets
				gA = repository.getGroupById(10001970059)
				# Ice Hockey / Switzerland / NLA
				gB = repository.getGroupById(1000094972)

				group = repository.getClosestCommonParentGroup(gA, gB)
				# Switzerland
				expect(group.get('id')).toBe(1000461911)

				# --- Test 3 ---
				# Volleyball / EuroVolley / Tournament Bets
				gA = repository.getGroupById(1000189254)
				# Ice Hockey / Switzerland / NLA
				gB = repository.getGroupById(1000094972)

				#group = repository.getClosestCommonParentGroup(gA, gB)
				# root
				#expect(group.get('id')).toBe(1)

				# --- Test 4 ---
				# Ice Hockey / Switzerland / Base Bets
				gA = repository.getGroupById(10001970059)
				# Ice Hockey / Switzerland
				gB = repository.getGroupById(1000461911)

				group = repository.getClosestCommonParentGroup(gA, gB)
				# Ice Hockey
				expect(group.get('id')).toBe(1000093191)

				# --- Test 5 ---
				# Ice Hockey / Switzerland
				gA = repository.getGroupById(1000461911)
				# Ice Hockey / Switzerland / Base Bets
				gB = repository.getGroupById(10001970059)

				group = repository.getClosestCommonParentGroup(gA, gB)
				# Ice Hockey
				expect(group.get('id')).toBe(1000093191)


		describe 'Decorate highlighted groups', ->

			beforeEach ->
				repository.reset()

			it 'adds and removes highlight data when highlighted groups are fetched', ->
				flatGroups = do spawnGroupData
				repository._onGroupsReceived flatGroups

				groupA = repository.getGroupById(1000461840)
				groupB = repository.getGroupById(1000461910)
				groupC = repository.getGroupById(1000461911)

				expect(groupA.get('highlighted')).not.toBeDefined()
				expect(groupA.get('highlightedSortOrder')).not.toBeDefined()
				expect(groupB.get('highlighted')).not.toBeDefined()
				expect(groupB.get('highlightedSortOrder')).not.toBeDefined()
				expect(groupC.get('highlighted')).not.toBeDefined()
				expect(groupC.get('highlightedSortOrder')).not.toBeDefined()

				highlightDecorate1 = do spawnHighlightDecorate1
				repository._onGroupsHighlighedReceived highlightDecorate1

				groupA = repository.getGroupById(1000461840)
				groupB = repository.getGroupById(1000461910)
				groupC = repository.getGroupById(1000461911)

				expect(groupA.get('highlighted')).toBe(true)
				expect(groupA.get('highlightedSortOrder')).toBe('10')
				expect(groupB.get('highlighted')).toBe(true)
				expect(groupB.get('highlightedSortOrder')).toBe('20')
				expect(groupC.get('highlighted')).toBe(true)
				expect(groupC.get('highlightedSortOrder')).toBe('30')

				highlightDecorate2 = do spawnHighlightDecorate2
				repository._onGroupsHighlighedReceived highlightDecorate2

				groupA = repository.getGroupById(1000461840)
				groupB = repository.getGroupById(1000461910)
				groupC = repository.getGroupById(1000461911)

				expect(groupA.get('highlighted')).toBe(true)
				expect(groupA.get('highlightedSortOrder')).toBe('10')
				expect(groupB.get('highlighted')).not.toBeDefined()
				expect(groupB.get('highlightedSortOrder')).not.toBeDefined()
				expect(groupC.get('highlighted')).toBe(true)
				expect(groupC.get('highlightedSortOrder')).toBe('30')