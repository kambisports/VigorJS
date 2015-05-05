Vigor = require '../../../../dist/vigor'
ServiceRepository = Vigor.ServiceRepository
assert = require 'assert'
sinon = require 'sinon'

clock = undefined
serviceRepository = undefined

describe 'An ServiceRepository', ->

  beforeEach ->
    serviceRepository = new Vigor.ServiceRepository()
    clock = sinon.useFakeTimers()

  afterEach ->
    clock.restore()

  describe 'should aggregate changes to repository', ->

    it 'and send REPOSITORY_ADD on add events in repository', ->
      repositoryAddTriggerCounter = 0
      backboneAddTriggerCounter = 0
      addedModels = []

      serviceRepository.on 'add', () ->
        backboneAddTriggerCounter++

      serviceRepository.on ServiceRepository::REPOSITORY_ADD, (added) ->
        repositoryAddTriggerCounter++
        addedModels = added

      serviceRepository.set [{ id: 1, data: 'Data1'}, { id: 2, data: 'Data2'}]

      clock.tick 100
      assert.equal repositoryAddTriggerCounter, 1
      assert.equal backboneAddTriggerCounter, 2
      assert.equal addedModels.length, 2

    it 'and send REPOSITORY_REMOVE on remove events in repository', ->
      repositoryRemoveTriggerCounter = 0
      backboneRemoveTriggerCounter = 0
      removedModels = []

      serviceRepository.set [{ id: 1, data: 'Data1'}, { id: 2, data: 'Data2'}, {id: 3, data: 'Data3'}]

      serviceRepository.on 'remove', () ->
        backboneRemoveTriggerCounter++

      serviceRepository.on ServiceRepository::REPOSITORY_REMOVE, (removed) ->
        repositoryRemoveTriggerCounter++
        removedModels = removed

      serviceRepository.set [{ id: 2, data: 'Data2'}]

      clock.tick 100

      assert.equal repositoryRemoveTriggerCounter, 1
      assert.equal backboneRemoveTriggerCounter, 2
      assert.equal serviceRepository.models.length, 1
      assert.equal removedModels.length, 2

    it 'and send REPOSITORY_CHANGE on change events in repository', ->
      repositoryChangeTriggerCounter = 0
      backboneChangeTriggerCounter = 0
      changedModels = []

      serviceRepository.set [{ id: 1, data: 'Data1'}, { id: 2, data: 'Data2'}, {id: 3, data: 'Data3'}]

      serviceRepository.on 'change', () ->
        backboneChangeTriggerCounter++

      serviceRepository.on ServiceRepository::REPOSITORY_CHANGE, (changed) ->
        repositoryChangeTriggerCounter++
        changedModels = changed

      serviceRepository.set [{ id: 1, data: 'Data12'}, { id: 2, data: 'Data22'}, { id: 3, data: 'Data3'}]

      clock.tick 100

      assert.equal repositoryChangeTriggerCounter, 1
      assert.equal backboneChangeTriggerCounter, 2
      assert.equal serviceRepository.models.length, 3
      assert.equal changedModels.length, 2

    it 'and send REPOSITORY_DIFF on changes in repository (add, remove, change)', ->
      repositoryDiffTriggerCounter = 0
      backboneChangeTriggerCounter = 0
      backboneAddTriggerCounter = 0
      backboneRemoveTriggerCounter = 0
      diffObj = {}

      serviceRepository.set [{ id: 1, data: 'Data1'}, { id: 2, data: 'Data2'}, {id: 3, data: 'Data3'}]
      clock.tick 100

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

      clock.tick 200

      assert.equal repositoryDiffTriggerCounter, 1
      assert.equal backboneChangeTriggerCounter, 1
      assert.equal backboneRemoveTriggerCounter, 1
      assert.equal backboneAddTriggerCounter, 2
      assert.equal serviceRepository.models.length, 4
      assert.equal diffObj.added.length, 2
      assert.equal diffObj.changed.length, 1
      assert.equal diffObj.removed.length, 1
      assert.equal diffObj.consolidated.length, 3
