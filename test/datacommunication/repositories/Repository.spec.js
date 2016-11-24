import {Repository} from  '../../../dist/vigor';
import assert from 'assert';
import sinon from 'sinon';

let clock = undefined;
let repository = undefined;

describe('An repository', function() {

  beforeEach(function() {
    repository = new Repository();
    clock = sinon.useFakeTimers();
  });

  afterEach(() => clock.restore());

  describe('should aggregate changes to repository', function() {

    it('and send REPOSITORY_ADD on add events in repository', function() {
      let repositoryAddTriggerCounter = 0;
      let backboneAddTriggerCounter = 0;
      let addedModels = [];

      repository.on('add', () => backboneAddTriggerCounter++);

      repository.on(repository.REPOSITORY_ADD, (added) => {
        repositoryAddTriggerCounter++;
        addedModels = added;
      });

      repository.set([{ id: 1, data: 'Data1'}, { id: 2, data: 'Data2'}]);

      clock.tick(99);
      assert.equal(backboneAddTriggerCounter, 2);
      assert.equal(repositoryAddTriggerCounter, 0);

      clock.tick(100);
      assert.equal(backboneAddTriggerCounter, 2);
      assert.equal(repositoryAddTriggerCounter, 1);
      assert.equal(addedModels.length, 2);
    });

    it('and send REPOSITORY_REMOVE on remove events in repository', function() {
      let repositoryRemoveTriggerCounter = 0;
      let backboneRemoveTriggerCounter = 0;
      let removedModels = [];

      repository.set([{ id: 1, data: 'Data1'}, { id: 2, data: 'Data2'}, {id: 3, data: 'Data3'}]);

      clock.tick(100);

      repository.on('remove', () => backboneRemoveTriggerCounter++);

      repository.on(repository.REPOSITORY_REMOVE, function(removed) {
        repositoryRemoveTriggerCounter++;
        removedModels = removed;
      });

      repository.set([{ id: 2, data: 'Data2'}]);

      clock.tick(200);
      assert.equal(backboneRemoveTriggerCounter, 2);
      assert.equal(repositoryRemoveTriggerCounter, 1);
      assert.equal(repository.models.length, 1);
      assert.equal(removedModels.length, 2);
    });

    it('and send REPOSITORY_CHANGE on change events in repository', function() {
      let repositoryChangeTriggerCounter = 0;
      let backboneChangeTriggerCounter = 0;
      let changedModels = [];

      repository.set([{ id: 1, data: 'Data1'}, { id: 2, data: 'Data2'}, {id: 3, data: 'Data3'}]);

      clock.tick(100);
      repository.on('change', () => backboneChangeTriggerCounter++);

      repository.on(repository.REPOSITORY_CHANGE, function(changed) {
        repositoryChangeTriggerCounter++;
        changedModels = changed;
      });

      repository.set([{ id: 1, data: 'Data12'}, { id: 2, data: 'Data22'}, { id: 3, data: 'Data3'}]);

      clock.tick(200);
      assert.equal(repositoryChangeTriggerCounter, 1);
      assert.equal(backboneChangeTriggerCounter, 2);
      assert.equal(repository.models.length, 3);
      assert.equal(changedModels.length, 2);
    });

    return it('and send REPOSITORY_DIFF on changes in repository (add, remove, change)', function() {
      let repositoryDiffTriggerCounter = 0;
      let backboneChangeTriggerCounter = 0;
      let backboneAddTriggerCounter = 0;
      let backboneRemoveTriggerCounter = 0;
      let diffObj = {};

      repository.set([{ id: 1, data: 'Data1'}, { id: 2, data: 'Data2'}, {id: 3, data: 'Data3'}]);

      clock.tick(100);
      repository.on('change', () => backboneChangeTriggerCounter++);
      repository.on('add', () => backboneAddTriggerCounter++);
      repository.on('remove', () => backboneRemoveTriggerCounter++);

      repository.on(repository.REPOSITORY_DIFF, (aggregatedChanges) => {
        repositoryDiffTriggerCounter++;
        diffObj = aggregatedChanges;
      });

      repository.set([
        { id: 1, data: 'Data1'}, // unchanged item
        { id: 2, data: 'Data22'}, // updated value in item
        // { id: 3, data: 'Data3'}, removed item since it's not part of new data set
        { id: 4, data: 'Data4'}, // added item
        { id: 5, data: 'Data5'} // added item
      ]);

      clock.tick(200);
      assert.equal(repositoryDiffTriggerCounter, 1);
      assert.equal(backboneChangeTriggerCounter, 1);
      assert.equal(backboneRemoveTriggerCounter, 1);
      assert.equal(backboneAddTriggerCounter, 2);
      assert.equal(repository.models.length, 4);
      assert.equal(diffObj.added.length, 2);
      assert.equal(diffObj.changed.length, 1);
      assert.equal(diffObj.removed.length, 1);
      assert.equal(diffObj.consolidated.length, 3);
    });
  });

  describe('when using helper methods', function() {
    it('isEmpty should tell if the collection is empty or not', function() {
      let empty = repository.isEmpty();
      assert.equal(empty, true);

      repository.set({ id: 1, data: 'Data1'});

      empty = repository.isEmpty();
      assert.equal(empty, false);
    });

    it('getByIds should return an array of models when given an array of ids', function() {
      repository.set([{ id: 1, data: 'Data1'}, { id: 2, data: 'Data2'}]);
      const models = repository.getByIds([1, 2]);
      assert.deepEqual(models[0].attributes, { id: 1, data: 'Data1'});
      assert.deepEqual(models[1].attributes, { id: 2, data: 'Data2'});
    });
  });
});
