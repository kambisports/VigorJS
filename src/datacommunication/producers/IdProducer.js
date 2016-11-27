import _ from 'underscore';
import Producer from 'datacommunication/producers/Producer';
// ## IdProducer
//
// An IdProducer produces data for multiple models.
//
// When an ordinary producer produces data, it produces all of its data to all of its subscribers.<br/>
// An IdProducer produces data for multiple data models, each of which has its own id.
// A subscription to an IdProducer specifies an id which corresponds to the model it is interested in.
// When a model's data changes, the IdProducer produces the data for that model to the subscribers that
// are subscribed to that model's id.


class IdProducer extends Producer {

  // This is the type of the model ids.<br/>
  // This should be value types, and are numbers by default.<br/>
  // Trying to add a subscription with an invalid type throws an error.
  get idType() {
    return this._idType || typeof 0;
  }

  set idType(type) {
    this._idType = type;
  }

  constructor() {
    super(...arguments);
    // An array containing the ids of the models that have been added, removed
    // or updated since the last time data was produced
    this.updatedIds = [];

    // A map of the subscriptions to this producer. The keys of this map are model ids
    // and the values are arrays of subscription options objects.
    this.subscriptions = {};
  }


  // **subscribe**<br/>
  // @param [options]: Object<br/>
  // Subsciption options. Can be used to get the id to unsubscribe from.
  //
  // Subscribe to the producer, if the id is of valid type.
  subscribe(options) {
    const id = this.idForOptions(options);
    if (typeof id !== this.idType) {
      throw `expected the subscription key to be a ${this.idType} but got a ${typeof subscriptionKey}`;
    }
    if (this.subscriptions[id]) {
      this.subscriptions[id].push(options);
    } else {
      this.subscriptions[id] = [options];
    }

    return this.produceDataSync(id);
  }

  // **onDiffInRepository**<br/>
  // @param [repository]: [Repository](Repository.html)<br/>
  // The repository whose data changed.
  //
  // @param [diff]: Object<br/>
  // An object containing arrays of data items that were added, removed and changed
  //
  // Handles updates from repositories. Filters the given models to only those that have subscriptions
  // and produces data for them.
  onDiffInRepository(repository, diff) {
    const addRemoveMap = (model) => {
      const id = this.idForModel(model, repository);
      if (_.isArray(id)) {
        return _.filter(id, this.hasId.bind(this));
      } else if (this.hasId(id)) {
        return id;
      }
    };

    const changeMap = (model) => {
      if (this.shouldPropagateModelChange(model, repository)) {
        let id = this.idForModel(model, repository);
        if (_.isArray(id)) {
          return _.filter(id, this.hasId.bind(this));
        } else if (this.hasId(id)) {
          return id;
        }
      }
    };

    const addedModelIds = _.map(diff.added, addRemoveMap);
    const removedModelIds = _.map(diff.removed, addRemoveMap);
    const updatedModelIds = _.map(diff.changed, changeMap);

    let ids = _.flattenDepth([addedModelIds, removedModelIds, updatedModelIds], 2);
    ids = _.compact(ids);

    this.produceDataForIds(ids);
  }


  // **produceDataForIds**<br/>
  // @param [ids]: Array of idTypes<br/>
  // An array of model ids to produce data for. Defaults to all subscribed models.<br/>
  //
  // Produces data for all given model ids.
  produceDataForIds(ids = this.allIds()) {
    this.updatedIds = _.uniq(this.updatedIds.concat(ids));
    return this.produceData();
  }

  // **allIds**<br/>
  // @returns [ids]: Array of idTypes<br/>
  // All subscribed ids.
  //
  // Returns an array of all subscribed ids.
  allIds() {
    let ids = _.keys(this.subscriptions);

    if (this.idType === (typeof 0)) {
      ids = _.map(ids, id => parseInt(id, 10));
    }

    return ids;
  }

  // **produceData**<br/>
  // Aynchronously produces data for all models whose data has changed since the last time data was produced.

  // **produceDataSync**<br/>
  // @param [id]: idType<br/>
  // The id to produce data for. Defaults to all ids whose data has changed since the last time data was produced.
  //
  // Synchronously produces data for all models whose data has changed since the last time data was produced. If an id is supplied, only data for the model with that id is produced.
  produceDataSync(id) {
    if (id) {
      return this.produce([id]);

    } else if (this.updatedIds.length > 0) {
      let ids = this.updatedIds.slice();
      this.updatedIds.length = 0;

      return this.produce(ids);
    }
  }


  // **unsubscribe** <br/>
  // @param [options]: Object <br/>
  // Subsciption options. Can be used to get the id to unsubscribe from. This must be the same reference as the options used when subscribing (i.e. ===).
  //
  // Unsubscribe from the producer.
  unsubscribe(options) {
    const id = this.idForOptions(options);
    const subscription = this.subscriptions[id];
    if (subscription) {
      const index = subscription.indexOf(options);
      if (index !== -1) {
        subscription.splice(index, 1);

        if (subscription.length === 0) {
          delete this.subscriptions[id];
        }
      }
    }
  }

  // **produce**<br/>
  // @param [ids]: Array of idTypes<br/>
  // List of ids to produce data for.
  //
  // Produce (gathered, decorated and validated) data for the ids.
  produce(ids) {
    let data;
    ids.forEach((id) => {
      data = this.currentData(id) || {};
      data.id = id;
      data = this.decorate(data);
      this._validateContract(data);

      _.each(this.registeredComponents, (component) => {
        if (id === this.idForOptions(component.options)) {
          return component.callback(data);
        }
      });

    });
  }

  // **currentData**<br/>
  // @param [id]: The id to produce data for
  //
  // This is where the actual collection of the data is done. <br/>
  currentData() {}
    // default implementation is a noop

  // **hasId**<br/>
  // @param [id]: idType<br/>
  // The id to check for.
  //
  // @returns [hasId]: boolean<br/>
  // True if there is a subscription for the given id, false otherwise.
  //
  // Returns true if there is a subscription for the given id, otherwise returns false.
  hasId(id) {
    return !(
      this.subscriptions[id] === null ||
      typeof(this.subscriptions[id]) === 'undefined'
    );
  }


  // **shouldPropagateModelChange**<br/>
  // @param [model]: Object<br/>
  // A model
  //
  // @param [repository]: [Repository](Repository.html)<br/>
  // The repository which contains the model.<br/>
  //
  // Called when a model changes to determine whether to produce data for the model. If true, then data for the model will be produced for this change.
  shouldPropagateModelChange() {
    return true;
  }

  // **idForModel**<br/>
  // @param [model]: Object<br/>
  // A model
  //
  // @param [repository]: [Repository](Repository.html)<br/>
  // The repository which contains the model.
  //
  // @returns [id]: idType or array of idTypes<br/>
  // The internal id of the given model, or an array of internal ids which correspond to the given model.
  //
  // Translates a model to an id or array of ids of type idType which uniquely identifies the model internally to this producer.
  idForModel(model) {
    return model.id;
  }

  // **idForOptions**<br/>
  // @param [options]: Object<br/>
  // A subscription options object.
  //
  // @returns [id]: idType<br/>
  // The internal id of the model that the subscription options refer to.
  //
  // Translates subscription options to an id of type idType which uniquely identifies the model internally to this producer.
  idForOptions(options) {
    return options.id;
  }
}

export default IdProducer;
