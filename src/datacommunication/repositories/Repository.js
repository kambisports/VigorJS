import _ from 'underscore';
import {Collection} from 'backbone';
//  ## Repository
//
// The Repository extends a [Backbone Collection](http://backbonejs.org/#Collection)
// and adds functionality for diffing and throttling data
//
//

class Repository extends Collection {

  get REPOSITORY_DIFF() {
    return 'repository_diff';
  }

  get REPOSITORY_ADD() {
    return 'repository_add';
  }

  get REPOSITORY_CHANGE() {
    return 'repository_change';
  }

  get REPOSITORY_REMOVE() {
    return 'repository_remove';
  }
  // Plain object holding reference to all the Backbone Collection models **added** since last throttled batch
  constructor(...args) {
    super(...args);
    this._onAdd = this._onAdd.bind(this);
    this._onChange = this._onChange.bind(this);
    this._onRemove = this._onRemove.bind(this);
    this._triggerUpdates = this._triggerUpdates.bind(this);
  }


  initialize() {
    super.initialize(...arguments);
    this.cid = this.cid || _.uniqueId('c');

    this._throttledAddedModels = {};
    // Plain object holding reference to all the Backbone Collection models **updated** since last throttled batch
    this._throttledChangedModels = {};
    // Plain object holding reference to all the Backbone Collection models **removed** since last throttled batch
    this._throttledRemovedModels = {};

    // Reference to a [throttled](http://underscorejs.org/#throttle) version of the _triggerUpdates
    // function in order to avoid flooding the listeners
    this._throttledTriggerUpdates = _.throttle(this._triggerUpdates, 100, {leading: false});

    this.addThrottledListeners();
  }

  // **addThrottledListeners** <br/>
  // Catch all events triggered from Backbone Collection in order to make throttling possible.
  // It still bubbles the event for outside subscribers.
  addThrottledListeners() {
    this.on('all', this._onAll);
  }

  // **getByIds** <br/>
  // @param [ids]: Array <br/>
  // @return models: Array
  getByIds(ids) {
    const models = [];
    for (let i = 0; i < ids.length; i++) {
      let id = ids[i];
      models.push(this.get(id));
    }
    return models;
  }

  isEmpty() {
    return this.models.length <= 0;
  }

  // **_onAll** <br/>
  // see *addThrottledListeners*
  _onAll(event, model) {
    switch (event) {
      case 'add': this._onAdd(model); break;
      case 'change': this._onChange(model); break;
      case 'remove': this._onRemove(model); break;
    }

    this._throttledTriggerUpdates();
  }

  _onAdd(model) {
    this._throttledAddedModels[model.id] = model;
  }

  _onChange(model) {
    this._throttledChangedModels[model.id] = model;
  }

  _onRemove(model) {
    this._throttledRemovedModels[model.id] = model;
  }

  _throttledAdd() {
    const event = Repository.prototype.REPOSITORY_ADD;
    const models = _.values(this._throttledAddedModels);
    this._throttledAddedModels = {};
    return this._throttledEvent(event, models, event);
  }

  _throttledChange() {
    const event = Repository.prototype.REPOSITORY_CHANGE;
    const models = _.values(this._throttledChangedModels);
    this._throttledChangedModels = {};
    return this._throttledEvent(event, models, event);
  }

  _throttledRemove() {
    const event = Repository.prototype.REPOSITORY_REMOVE;
    const models = _.values(this._throttledRemovedModels);
    this._throttledRemovedModels = {};
    return this._throttledEvent(event, models, event);
  }

  _throttledEvent(event, models, eventRef) {
    if (models.length > 0) {
      this.trigger(event, models, eventRef);
    }
    return models;
  }


  // **_throttledDiff** <br/>
  // @param [added]: Array <br/>
  // @param [changed]: Array <br/>
  // @param [removed]: Array <br/>
  //
  // An event type called REPOSITORY_DIFF is added to the repository which supplies a consolidated
  // response with all the added, removed and updated models since last throttled batch
  _throttledDiff(added, changed, removed) {
    const  event = Repository.prototype.REPOSITORY_DIFF;
    if (added.length || changed.length || removed.length) {

      added = _.difference(added, removed);
      const consolidated = _.uniq(added.concat(changed));

      const models = {
        added,
        changed,
        removed,
        consolidated
      };

      this.trigger(event, models, event);
    }
  }

  _triggerUpdates() {
    this._throttledDiff(
      this._throttledAdd(),
      this._throttledChange(),
      this._throttledRemove()
    );
  }
}

export default Repository;
