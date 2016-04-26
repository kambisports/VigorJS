Vigor = require '../../../../dist/vigor'
assert = require 'assert'
sinon = require 'sinon'

clock = undefined
repository = undefined

describe 'An repository', ->

  beforeEach ->
    repository = new Vigor.Repository()
    clock = sinon.useFakeTimers()

  afterEach ->
    clock.restore()

  describe 'should aggregate changes to repository', ->

    it 'and send REPOSITORY_ADD on add events in repository', ->
      repositoryAddTriggerCounter = 0
      backboneAddTriggerCounter = 0
      addedModels = []

      repository.on 'add', ->
        backboneAddTriggerCounter++

      repository.on repository.REPOSITORY_ADD, (added) ->
        repositoryAddTriggerCounter++
        addedModels = added

      repository.set [{ id: 1, data: 'Data1'}, { id: 2, data: 'Data2'}]

      #clock.tick 99
      setTimeout 99, ->
        assert.equal backboneAddTriggerCounter, 2
        assert.equal repositoryAddTriggerCounter, 0

        #clock.tick 100
        setTimeout 1, ->
          assert.equal backboneAddTriggerCounter, 2
          assert.equal repositoryAddTriggerCounter, 1
          assert.equal addedModels.length, 2

    it 'and send REPOSITORY_REMOVE on remove events in repository', ->
      repositoryRemoveTriggerCounter = 0
      backboneRemoveTriggerCounter = 0
      removedModels = []

      repository.set [{ id: 1, data: 'Data1'}, { id: 2, data: 'Data2'}, {id: 3, data: 'Data3'}]

      #clock.tick 100
      setTimeout 100, ->
        repository.on 'remove', ->
          backboneRemoveTriggerCounter++

        repository.on repository.REPOSITORY_REMOVE, (removed) ->
          repositoryRemoveTriggerCounter++
          removedModels = removed

        repository.set [{ id: 2, data: 'Data2'}]
        
        #clock.tick 200
        setTimeout 100, ->
          assert.equal backboneRemoveTriggerCounter, 2
          assert.equal repositoryRemoveTriggerCounter, 1
          assert.equal repository.models.length, 1
          assert.equal removedModels.length, 2

    it 'and send REPOSITORY_CHANGE on change events in repository', ->
      repositoryChangeTriggerCounter = 0
      backboneChangeTriggerCounter = 0
      changedModels = []

      repository.set [{ id: 1, data: 'Data1'}, { id: 2, data: 'Data2'}, {id: 3, data: 'Data3'}]

      #clock.tick 100
      setTimeout 100, ->
        repository.on 'change', ->
          backboneChangeTriggerCounter++

        repository.on repository.REPOSITORY_CHANGE, (changed) ->
          repositoryChangeTriggerCounter++
          changedModels = changed

        repository.set [{ id: 1, data: 'Data12'}, { id: 2, data: 'Data22'}, { id: 3, data: 'Data3'}]

        #clock.tick 200
        setTimeout 100, ->
          assert.equal repositoryChangeTriggerCounter, 1
          assert.equal backboneChangeTriggerCounter, 2
          assert.equal repository.models.length, 3
          assert.equal changedModels.length, 2

    it 'and send REPOSITORY_DIFF on changes in repository (add, remove, change)', ->
      repositoryDiffTriggerCounter = 0
      backboneChangeTriggerCounter = 0
      backboneAddTriggerCounter = 0
      backboneRemoveTriggerCounter = 0
      diffObj = {}

      repository.set [{ id: 1, data: 'Data1'}, { id: 2, data: 'Data2'}, {id: 3, data: 'Data3'}]

      #clock.tick 100
      setTimeout 100, ->
        repository.on 'change', () ->
          backboneChangeTriggerCounter++

        repository.on 'add', () ->
          backboneAddTriggerCounter++

        repository.on 'remove', () ->
          backboneRemoveTriggerCounter++

        repository.on repository.REPOSITORY_DIFF, (aggregatedChanges) ->
          repositoryDiffTriggerCounter++
          diffObj = aggregatedChanges

        repository.set [
          { id: 1, data: 'Data1'} # unchanged item
          { id: 2, data: 'Data22'} # updated value in item
          # { id: 3, data: 'Data3'}, removed item since it's not part of new data set
          { id: 4, data: 'Data4'} # added item
          { id: 5, data: 'Data5'} # added item
        ]

        #clock.tick 200
        setTimeout 100, ->
          assert.equal repositoryDiffTriggerCounter, 1
          assert.equal backboneChangeTriggerCounter, 1
          assert.equal backboneRemoveTriggerCounter, 1
          assert.equal backboneAddTriggerCounter, 2
          assert.equal repository.models.length, 4
          assert.equal diffObj.added.length, 2
          assert.equal diffObj.changed.length, 1
          assert.equal diffObj.removed.length, 1
          assert.equal diffObj.consolidated.length, 3

  describe 'when using helper methods', ->

    it 'isEmpty should tell if the collection is empty or not', ->
      empty = repository.isEmpty()
      assert.equal empty, true

      repository.set { id: 1, data: 'Data1'}

      empty = repository.isEmpty()
      assert.equal empty, false

    it 'getByIds should return an array of models when given an array of ids', ->
      repository.set [{ id: 1, data: 'Data1'}, { id: 2, data: 'Data2'}]
      models = repository.getByIds([1, 2])
      assert.deepEqual models[0].attributes, { id: 1, data: 'Data1'}
      assert.deepEqual models[1].attributes, { id: 2, data: 'Data2'}
