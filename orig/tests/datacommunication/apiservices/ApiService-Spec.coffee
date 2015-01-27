define (require) ->

	ApiServiceHelper = require 'datacommunication/apiservices/ApiServiceHelper'

	ServiceRepository = require 'datacommunication/repositories/ServiceRepository'
	ApiService = require 'datacommunication/apiservices/ApiService'

	serviceRepository = undefined
	apiService = undefined

	describe 'An ApiService', ->

		beforeEach ->
			spyOn(ApiServiceHelper, 'getUrl').andReturn 1
			spyOn(ApiServiceHelper, 'sync').andReturn 1

			# Mock singleton instances
			serviceRepository = new ServiceRepository()
			apiService = new ApiService(serviceRepository)


		describe 'polling', ->

			it 'should start when repository triggers event START_POLLING', ->

				spyOn(apiService, '_startPolling').andReturn 1
				do apiService.bindRepositoryListeners

				serviceRepository.interestedInUpdates 'TestRepoName'

				expect(apiService._startPolling).toHaveBeenCalled()

			it 'should stop when repository triggers event STOP_POLLING', ->

				serviceRepository.interestedInUpdates 'TestRepoName'

				spyOn(apiService, '_stopPolling').andReturn 1
				do apiService.bindRepositoryListeners

				serviceRepository.notInterestedInUpdates 'TestRepoName'

				expect(apiService._stopPolling).toHaveBeenCalled()