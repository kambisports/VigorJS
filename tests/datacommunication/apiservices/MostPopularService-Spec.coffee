define (require) ->

	MostPopularRepository = require 'datacommunication/repositories/mostpopular/MostPopularRepository'
	MostPopularService = require 'datacommunication/apiservices/MostPopularService'

	mostPopularRepository = undefined
	mostPopularService = undefined

	describe 'A MostPopularService', ->

		beforeEach ->
			# Mock singleton instances
			mostPopularRepository = do MostPopularRepository.makeTestInstance
			mostPopularService = MostPopularService.makeTestInstance mostPopularRepository

		describe 'polling', ->

			it 'should start when there are active listeners on MostPopularRepository', ->
				spyOn(mostPopularService, '_startPolling').andReturn 1

				# rebind listeners in order for the spy to work correctly
				do mostPopularService._bindRepositoryListeners

				mostPopularRepository.on 'testListener', () ->

				expect(mostPopularService._startPolling).toHaveBeenCalled()

			it 'should stop when there are no active listeners on MostPopularRepository', ->
				spyOn(mostPopularService, '_stopPolling').andReturn 1

				# rebind listeners in order for the spy to work correctly
				do mostPopularService._bindRepositoryListeners

				mostPopularRepository.on 'testListener', () ->
				mostPopularRepository.off 'testListener', () ->

				expect(mostPopularService._stopPolling).toHaveBeenCalled()


