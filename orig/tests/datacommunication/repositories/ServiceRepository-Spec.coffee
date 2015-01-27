define (require) ->


	ServiceRepository = require 'datacommunication/repositories/ServiceRepository'

	serviceRepository = undefined

	describe 'An ServiceRepository', ->

		beforeEach ->
			serviceRepository = new ServiceRepository()

		describe 'should send event', ->

			it 'START_POLLING when a new producer registers for interest', ->
				triggeredStartPollingCount = 0

				serviceRepository.on ServiceRepository::START_POLLING, () ->
					triggeredStartPollingCount++

				serviceRepository.interestedInUpdates 'TestProducer'

				expect(triggeredStartPollingCount).toBe 1


			it 'STOP_POLLING when producer unregisters for interest', ->

				triggeredStopPollingCount = 0
				serviceRepository.interestedInUpdates 'TestProducer'

				serviceRepository.on ServiceRepository::STOP_POLLING, () ->
					triggeredStopPollingCount++

				serviceRepository.notInterestedInUpdates 'TestProducer'

				expect(triggeredStopPollingCount).toBe 1

		describe 'should not send more than one event', ->

			it 'START_POLLING when a same producer re-registers for interest', ->
				triggeredStartPollingCount = 0

				serviceRepository.on ServiceRepository::START_POLLING, () ->
					triggeredStartPollingCount++

				serviceRepository.interestedInUpdates 'TestProducer'
				serviceRepository.interestedInUpdates 'TestProducer'

				expect(triggeredStartPollingCount).toBe 1

		describe 'should aggregate changes to repository', ->

			it 'and send REPOSITORY_ADD on add events in repository', ->
				repositoryAddTriggerCounter = 0
				backboneAddTriggerCounter = 0
				addedModels = []

				runs ->
					serviceRepository.on 'add', () ->
						backboneAddTriggerCounter++

					serviceRepository.on ServiceRepository::REPOSITORY_ADD, (added) ->
						repositoryAddTriggerCounter++
						addedModels = added

					serviceRepository.set [{ id: 1, data: 'Data1'},{ id: 2, data: 'Data2'}]

				waitsFor ->
					return repositoryAddTriggerCounter > 0

				runs ->
					expect(repositoryAddTriggerCounter).toBe 1
					expect(backboneAddTriggerCounter).toBe 2
					expect(addedModels.length).toBe 2

			it 'and send REPOSITORY_REMOVE on remove events in repository', ->
				repositoryRemoveTriggerCounter = 0
				backboneRemoveTriggerCounter = 0
				removedModels = []

				serviceRepository.set [{ id: 1, data: 'Data1'},{ id: 2, data: 'Data2'}, {id: 3, data: 'Data3'}]

				runs ->
					serviceRepository.on 'remove', () ->
						backboneRemoveTriggerCounter++

					serviceRepository.on ServiceRepository::REPOSITORY_REMOVE, (removed) ->
						repositoryRemoveTriggerCounter++
						removedModels = removed

					serviceRepository.set [{ id: 2, data: 'Data2'}]

				waitsFor ->
					return repositoryRemoveTriggerCounter > 0

				runs ->
					expect(repositoryRemoveTriggerCounter).toBe 1
					expect(backboneRemoveTriggerCounter).toBe 2
					expect(serviceRepository.models.length).toBe 1
					expect(removedModels.length).toBe 2

			it 'and send REPOSITORY_CHANGE on change events in repository', ->
				repositoryChangeTriggerCounter = 0
				backboneChangeTriggerCounter = 0
				changedModels = []

				serviceRepository.set [{ id: 1, data: 'Data1'},{ id: 2, data: 'Data2'}, {id: 3, data: 'Data3'}]

				runs ->
					serviceRepository.on 'change', () ->
						backboneChangeTriggerCounter++

					serviceRepository.on ServiceRepository::REPOSITORY_CHANGE, (changed) ->
						repositoryChangeTriggerCounter++
						changedModels = changed

					serviceRepository.set [{ id: 1, data: 'Data12'}, { id: 2, data: 'Data22'}, { id: 3, data: 'Data3'}]

				waitsFor ->
					return repositoryChangeTriggerCounter > 0

				runs ->
					expect(repositoryChangeTriggerCounter).toBe 1
					expect(backboneChangeTriggerCounter).toBe 2
					expect(serviceRepository.models.length).toBe 3
					expect(changedModels.length).toBe 2

			it 'and send REPOSITORY_DIFF on changes in repository (add, remove, change)', ->
				repositoryDiffTriggerCounter = 0
				backboneChangeTriggerCounter = 0
				backboneAddTriggerCounter = 0
				backboneRemoveTriggerCounter = 0
				diffObj = {}

				serviceRepository.set [{ id: 1, data: 'Data1'},{ id: 2, data: 'Data2'}, {id: 3, data: 'Data3'}]

				runs ->
					serviceRepository.on 'change', () ->
						backboneChangeTriggerCounter++

					serviceRepository.on 'add', () ->
						backboneAddTriggerCounter++

					serviceRepository.on 'remove', () ->
						backboneRemoveTriggerCounter++

					serviceRepository.on ServiceRepository::REPOSITORY_DIFF, (aggregatedChanges) ->
						repositoryDiffTriggerCounter++
						diffObj = aggregatedChanges

					serviceRepository.set [
						{ id: 1, data: 'Data1'} # unchanged item
						{ id: 2, data: 'Data22'} # updated value in item
						# { id: 3, data: 'Data3'}, removed item since it's not part of new data set
						{ id: 4, data: 'Data4'} # added item
						{ id: 5, data: 'Data5'} # added item
					]

				waitsFor ->
					return repositoryDiffTriggerCounter > 0

				runs ->
					console.log diffObj
					expect(repositoryDiffTriggerCounter).toBe 1
					expect(backboneChangeTriggerCounter).toBe 1
					expect(backboneRemoveTriggerCounter).toBe 1
					expect(backboneAddTriggerCounter).toBe 2
					expect(serviceRepository.models.length).toBe 4
					expect(diffObj.added.length).toBe 4
					expect(diffObj.changed.length).toBe 1
					expect(diffObj.removed.length).toBe 1
