define (require) ->

	GroupsService = require 'datacommunication/apiservices/GroupsService'
	GroupsHighlightedService = require 'datacommunication/apiservices/GroupsHighlightedService'
	GroupsRepository = require 'datacommunication/repositories/groups/GroupsRepository'

	describe 'GroupsRepository', ->

		path = 'js/spec/datacommunication/repositories/groups/'
		dataGroups = path + 'Groups-Data.json'
		dataGroupHighlight = path + 'GroupHighlight-Data.json'
		dataGroupAlphabetical = path + 'GroupAlphabetical-Data.json'
		dataGroupHighlightSort1 = path + 'GroupHighlightSort1-Data.json'
		dataGroupHighlightSort2 = path + 'GroupHighlightSort2-Data.json'
		dataGroupHighlightDecorate1 = path + 'GroupHighlightDecorate1-Data.json'
		dataGroupHighlightDecorate2 = path + 'GroupHighlightDecorate2-Data.json'

		groupsService = undefined
		groupsHighlightedService = undefined
		repository = undefined

		describe 'sortLeafGroups', ->

			beforeEach ->
				groupsHighlightedService = GroupsHighlightedService
				groupsHighlightedService.service.url = dataGroupHighlight
				groupsService = GroupsService
				groupsService.service.url = dataGroups

				repository = GroupsRepository
				repository.reset()

			afterEach ->
				groupsHighlightedService = undefined
				groupsService = undefined

			it '(one group) sorts a list of event group models according to event group tree', ->
				runs () ->
					groupsService.service.fetch()
					spyOn(groupsService.service, 'parse').andCallThrough()

				waitsFor () ->
					groupsService.service.parse.wasCalled
				, 'Group data (mock) to be fetched', 1000

				runs () ->
					groupsHighlightedService.service.fetch()
					spyOn(groupsHighlightedService.service, 'parse').andCallThrough()

				waitsFor () ->
					groupsHighlightedService.service.parse.wasCalled
				, 'Highlighted group data (mock) to be fetched', 1000

				runs () ->
					# All Football / England
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
				runs () ->
					groupsService.service.fetch()
					spyOn(groupsService.service, 'parse').andCallThrough()

				waitsFor () ->
					groupsService.service.parse.wasCalled
				, 'Group data (mock) to be fetched', 1000

				runs () ->
					groupsHighlightedService.service.fetch()
					spyOn(groupsHighlightedService.service, 'parse').andCallThrough()

				waitsFor () ->
					groupsHighlightedService.service.parse.wasCalled
				, 'Highlighted group data (mock) to be fetched', 1000

				runs () ->
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
				runs () ->
					groupsService.service.fetch()
					spyOn(groupsService.service, 'parse').andCallThrough()

				waitsFor () ->
					groupsService.service.parse.wasCalled
				, 'Group data (mock) to be fetched', 1000

				runs () ->
					groupsHighlightedService.service.fetch()
					spyOn(groupsHighlightedService.service, 'parse').andCallThrough()

				waitsFor () ->
					groupsHighlightedService.service.parse.wasCalled
				, 'Highlighted group data (mock) to be fetched', 1000

				runs () ->
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
				runs () ->
					# override url
					groupsService.service.url = dataGroupAlphabetical

					groupsService.service.fetch()
					spyOn(groupsService.service, 'parse').andCallThrough()

				waitsFor () ->
					groupsService.service.parse.wasCalled
				, 'Group data (mock) to be fetched', 1000

				runs () ->
					groupsHighlightedService.service.fetch()
					spyOn(groupsHighlightedService.service, 'parse').andCallThrough()

				waitsFor () ->
					groupsHighlightedService.service.parse.wasCalled
				, 'Highlighted group data (mock) to be fetched', 1000

				runs () ->
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
				runs () ->
					# override url
					groupsHighlightedService.service.url = dataGroupHighlightSort1

					groupsService.service.fetch()
					spyOn(groupsService.service, 'parse').andCallThrough()

				waitsFor () ->
					groupsService.service.parse.wasCalled
				, 'Group data (mock) to be fetched', 1000

				runs () ->
					groupsHighlightedService.service.fetch()
					spyOn(groupsHighlightedService.service, 'parse').andCallThrough()

				waitsFor () ->
					groupsHighlightedService.service.parse.wasCalled
				, 'Highlighted group data (mock) to be fetched', 1000

				runs () ->
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
				runs () ->
					# override url
					groupsHighlightedService.service.url = dataGroupHighlightSort2

					groupsService.service.fetch()
					spyOn(groupsService.service, 'parse').andCallThrough()

				waitsFor () ->
					groupsService.service.parse.wasCalled
				, 'Group data (mock) to be fetched', 1000

				runs () ->
					groupsHighlightedService.service.fetch()
					spyOn(groupsHighlightedService.service, 'parse').andCallThrough()

				waitsFor () ->
					groupsHighlightedService.service.parse.wasCalled
				, 'Highlighted group data (mock) to be fetched', 1000

				runs () ->
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
				groupsHighlightedService = GroupsHighlightedService
				groupsHighlightedService.service.url = dataGroupHighlight
				groupsService = GroupsService
				groupsService.service.url = dataGroups

				repository = GroupsRepository
				repository.reset()

			afterEach ->
				groupsHighlightedService = undefined
				groupsService = undefined

			it 'returns the closest common parent group', ->
				runs () ->
					groupsService.service.fetch()
					spyOn(groupsService.service, 'parse').andCallThrough()

				waitsFor () ->
					groupsService.service.parse.wasCalled
				, 'Group data (mock) to be fetched', 1000

				runs () ->
					groupsHighlightedService.service.fetch()
					spyOn(groupsHighlightedService.service, 'parse').andCallThrough()

				waitsFor () ->
					groupsHighlightedService.service.parse.wasCalled
				, 'Highlighted group data (mock) to be fetched', 1000

				runs () ->
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
				groupsHighlightedService = GroupsHighlightedService
				groupsHighlightedService.service.url = dataGroupHighlight
				groupsService = GroupsService
				groupsService.service.url = dataGroups

				repository = GroupsRepository
				repository.reset()

			afterEach ->
				groupsHighlightedService = undefined
				groupsService = undefined

			it 'adds and removes highlight data when highlighted groups are fetched', ->
				runs () ->
					groupsService.service.fetch()
					spyOn(groupsService.service, 'parse').andCallThrough()
				waitsFor () ->
					groupsService.service.parse.wasCalled
				, 'Group data (mock) to be fetched', 1000

				runs () ->
					groupA = repository.getGroupById(1000461840)
					groupB = repository.getGroupById(1000461910)
					groupC = repository.getGroupById(1000461911)

					expect(groupA.get('highlighted')).not.toBeDefined()
					expect(groupA.get('highlightedSortOrder')).not.toBeDefined()
					expect(groupB.get('highlighted')).not.toBeDefined()
					expect(groupB.get('highlightedSortOrder')).not.toBeDefined()
					expect(groupC.get('highlighted')).not.toBeDefined()
					expect(groupC.get('highlightedSortOrder')).not.toBeDefined()

					groupsHighlightedService.service.url = dataGroupHighlightDecorate1
					groupsHighlightedService.service.fetch()
					spyOn(groupsHighlightedService.service, 'parse').andCallThrough()

				waitsFor () ->
					groupsHighlightedService.service.parse.wasCalled
				, 'Highlighted group data (mock) to be fetched', 1000

				runs () ->
					groupA = repository.getGroupById(1000461840)
					groupB = repository.getGroupById(1000461910)
					groupC = repository.getGroupById(1000461911)

					expect(groupA.get('highlighted')).toBe(true)
					expect(groupA.get('highlightedSortOrder')).toBe('10')
					expect(groupB.get('highlighted')).toBe(true)
					expect(groupB.get('highlightedSortOrder')).toBe('20')
					expect(groupC.get('highlighted')).toBe(true)
					expect(groupC.get('highlightedSortOrder')).toBe('30')

					groupsHighlightedService.service.url = dataGroupHighlightDecorate2
					# reset wasCalled
					groupsHighlightedService.service.parse.wasCalled = false
					groupsHighlightedService.service.fetch()

				waitsFor () ->
					groupsHighlightedService.service.parse.wasCalled
				, 'Highlighted group data (mock) to be fetched', 1000

				runs () ->
					groupA = repository.getGroupById(1000461840)
					groupB = repository.getGroupById(1000461910)
					groupC = repository.getGroupById(1000461911)

					expect(groupA.get('highlighted')).toBe(true)
					expect(groupA.get('highlightedSortOrder')).toBe('10')
					expect(groupB.get('highlighted')).not.toBeDefined()
					expect(groupB.get('highlightedSortOrder')).not.toBeDefined()
					expect(groupC.get('highlighted')).toBe(true)
					expect(groupC.get('highlightedSortOrder')).toBe('30')