define (require) ->

	GroupsService = require 'datacommunication/apiservices/GroupsService'
	GroupsHighlightedService = require 'datacommunication/apiservices/GroupsHighlightedService'
	GroupsRepository = require 'datacommunication/repositories/groups/GroupsRepository'

	describe 'GroupsRepository', ->

		###
		mockData = 'EventGroups';
		mockDataAlphabetical = 'EventGroupsAlphabetical';
		mockDataSorting = 'EventGroupsSorting';
		mockDataHighlight = 'EventGroupHighlight';
		mockDataHighlightSort1 = 'EventGroupHighlightSort1';
		mockDataHighlightSort2 = 'EventGroupHighlightSort2';
		###

		path = 'js/spec/datacommunication/repositories/groups/'
		dataEventGroups = path + 'EventGroups-Data.json'
		dataEventGroupHighlight = path + 'EventGroupHighlight-Data.json'
		dataEventGroupAlphabetical = path + 'EventGroupAlphabetical-Data.json'
		dataEventGroupHighlightSort1 = path + 'EventGroupHighlightSort1-Data.json'

		groupsService = undefined
		groupsHighlightedService = undefined
		repository = undefined

		describe 'sortLeafEventGroups', ->
			
			beforeEach ->
				groupsHighlightedService = GroupsHighlightedService
				groupsHighlightedService.service.url = dataEventGroupHighlight
				groupsService = GroupsService
				groupsService.service.url = dataEventGroups
				
				repository = groupsService.repository

			afterEach ->
				groupsHighlightedService = undefined
				groupsService = undefined

			it '(one group) sorts a list of event group models according to event group tree', ->
				runs () ->
					groupsService.service.fetch()
					spyOn(groupsService.service, 'parse').andCallThrough()

					groupsHighlightedService.service.fetch()
					spyOn(groupsHighlightedService.service, 'parse').andCallThrough()

				waitsFor () ->
					groupsService.service.parse.wasCalled and groupsHighlightedService.service.parse.wasCalled
				, 'Mock data to be fetched', 1000

				runs () ->
					# All Football / England
					groups = repository.getLeafEventGroups 1000461733
					groups = repository.sortLeafEventGroups groups

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

					groupsHighlightedService.service.fetch()
					spyOn(groupsHighlightedService.service, 'parse').andCallThrough()

				waitsFor () ->
					groupsService.service.parse.wasCalled and groupsHighlightedService.service.parse.wasCalled
				, 'Mock data to be fetched', 1000

				runs () ->
					# Ice Hochey
					groups = repository.getLeafEventGroups 1000093191
					groups = repository.sortLeafEventGroups groups

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

					groupsHighlightedService.service.fetch()
					spyOn(groupsHighlightedService.service, 'parse').andCallThrough()

				waitsFor () ->
					groupsService.service.parse.wasCalled and groupsHighlightedService.service.parse.wasCalled
				, 'Mock data to be fetched', 1000

				runs () ->
					# Alphabetically: Ice Hochey
					groups = repository.getLeafEventGroups 1000093191
					groups = repository.sortLeafEventGroups groups, true

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
					groupsService.service.url = dataEventGroupAlphabetical

					groupsService.service.fetch()
					spyOn(groupsService.service, 'parse').andCallThrough()

					groupsHighlightedService.service.fetch()
					spyOn(groupsHighlightedService.service, 'parse').andCallThrough()

				waitsFor () ->
					groupsService.service.parse.wasCalled and groupsHighlightedService.service.parse.wasCalled
				, 'Mock data to be fetched', 1000

				runs () ->
					# Alphabetically: Ice Hochey
					groups = repository.getLeafEventGroups 1000093191
					groups = repository.sortLeafEventGroups groups, true

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

			xit '(highlighted test 1) sorts a list of event group models according to highlighted sort order', ->
				runs () ->
					# override url
					groupsHighlightedService.service.url = dataEventGroupHighlightSort1

					groupsService.service.fetch()
					spyOn(groupsService.service, 'parse').andCallThrough()

					groupsHighlightedService.service.fetch()
					spyOn(groupsHighlightedService.service, 'parse').andCallThrough()

				waitsFor () ->
					groupsService.service.parse.wasCalled and groupsHighlightedService.service.parse.wasCalled
				, 'Mock data to be fetched', 1000

				runs () ->
					# Alphabetically: Ice Hochey
					groups = repository.getLeafEventGroups 1000093191
					groups = repository.sortLeafEventGroups groups

					_.each groups, (group) ->
						console.log group.get('name')

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