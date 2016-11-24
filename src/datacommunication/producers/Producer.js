import _ from 'underscore';
import {Model, Events} from 'backbone';
import Repository from 'datacommunication/repositories/Repository';
import validateContract from 'utils/validateContract';
// ## Producer
//
// A Producer listens to data changes in one or several repositories
// and produces data on a certain Production Key.
//
//

class Producer {

  static get extend() {
    return Model.extend;
  }

  // The production key that is used for subscribing to the producer. <br/>
  // This key should be overridden in the subclass.
  get PRODUCTION_KEY() {
   return this._productionKey;
  }

  set PRODUCTION_KEY(productionKey) {
   this._productionKey = productionKey;
  }

  // The repository (or repositories) that the producer listens to.
  get repositories() {
   return this._repositories || [];
  }

  set repositories(repositories) {
    this._repositories = repositories;
  }

  // The decorator(s) that is used for formatting the produced data.
  get decorators() {
   return this._decorators || [];
  }

  set decorators(decorators) {
    this._decorators = decorators;
  }


  constructor() {
    this.onDiffInRepository = this.onDiffInRepository.bind(this);
    this.registeredComponents = {};
    this.produceData = _.throttle(this.produceDataSync, 100);

    // Keeps track of if the producer has subscribed to its repositories or not.
    this._isSubscribedToRepositories = false;
  }


  getInstance() {
    if (this.instance == null) {
      this.instance = new this.constructor();
    }
    return this.instance;
  }


  // **addComponent** <br/>
  // @param [subscription]: Object <br/>
  // The subscription, which contains an id, a callback and options. <br/>
  //
  // Adds (subscribes) a component to the producer.
  addComponent(subscription) {
    const existingSubscription = this.registeredComponents[subscription.id];
    if (existingSubscription == null) {
      this.registeredComponents[subscription.id] = subscription;
      this.subscribe(subscription.options);

      if (!this._isSubscribedToRepositories) {
        this.subscribeToRepositories();
        this._isSubscribedToRepositories = true;
      }
    }
  }


  // **removeComponent** <br/>
  // @param [componentId]: String <br/>
  // The id of the component that should be removed. <br/>
  //
  // Removes a component (its subscription) from the producer.
  removeComponent(componentId) {
    const subscription = this.registeredComponents[componentId];

    if (subscription) {
      this.unsubscribe(subscription.options);
      delete this.registeredComponents[subscription.id];

      let shouldUnsubscribe = true;
      for (let component in this.registeredComponents) {
        shouldUnsubscribe = false;
        break;
      }

      if (shouldUnsubscribe) {
        this.unsubscribeFromRepositories();
        this._isSubscribedToRepositories = false;
      }
    }
  }


  // **subscribeToRepositories** <br/>
  // Subscribes to all the repositories. <br/>
  // Also registers the callback function if the repository has one.
  subscribeToRepositories() {
    this.repositories.forEach((repository) => {
      if (repository instanceof Repository) {
        this.subscribeToRepository(repository);
      } else if (repository.repository instanceof Repository && typeof repository.callback === 'string') {
        this.subscribeToRepository(repository.repository, this[repository.callback]);
      } else {
        throw 'unexpected format of producer repositories definition';
      }
    });
  }


  // **unsubscribeFromRepositories** <br/>
  // Unsubscribes from all the repositories.
  unsubscribeFromRepositories() {
    this.repositories.forEach((repository) => {
      if (repository instanceof Repository) {
        this.unsubscribeFromRepository(repository);
      } else if (repository.repository instanceof Repository && typeof repository.callback === 'string') {
        this.unsubscribeFromRepository(repository.repository);
      }
    });
  }


  // **subscribeToRepository** <br/>
  // @param [repository]: Object <br/>
  // The repository to subscribe to. <br/>
  // @param [callback]: String <br/>
  // The method that should be executed on repository diff.
  //
  // Sets up a subscription to a repository with a custom or predefined callback.
  subscribeToRepository(repository, callback) {
    if (!callback) {
      callback = diff => {
        return this.onDiffInRepository(repository, diff);
      };
    }

    this.listenTo(repository, Repository.prototype.REPOSITORY_DIFF, callback);
  }


  // **unsubscribeFromRepository** <br/>
  // @param [repository]: Object <br/>
  // The repository to unsubscribe from.
  //
  // Unsubscribes from a repository.
  unsubscribeFromRepository(repository) {
    this.stopListening(repository, Repository.prototype.REPOSITORY_DIFF);
  }


  // **subscribe** <br/>
  // Called when a component is added.
  subscribe() {
    this.produceDataSync();
  }


  // **onDiffInRepository** <br/>
  // Used as default callback when subscribing to a repository.
  onDiffInRepository() {
    this.produceData();
  }


  produceDataSync() {
    this.produce(this.currentData());
  }


  // ***produce*** <br/>
  // @param [data]: Object <br/>
  // The current data.
  //
  // This method is called by the produceDataSync method <br/>
  // and in turn calls methods for decoration of the current data <br/>
  // and validation of its contract.
  produce(data) {
    data = this.decorate(data);
    this._validateContract(data);
    for (let componentId in this.registeredComponents) {
      const component = this.registeredComponents[componentId];
      component.callback(data);
    }
  }


  // **currentData** <br/>
  // This is where the actual collection of the data is done. <br/>
  // Default implementation is a noop.
  currentData() {}

  // **unsubscribe** <br/>
  // Default implementation is a noop.
  unsubscribe(options) {}


  // **decorate** <br/>
  // @param [data]: Object <br/>
  // The data to decorate .<br/>
  // @return data: Object <br/>
  // The decorated data.
  //
  // Runs the assigned decorator(s) on the data.
  decorate(data) {
    for (let i = 0; i < this.decorators.length; i++) {
      const decorator = this.decorators[i];
      decorator(data);
    }
    return data;
  }


  modelToJSON(model) {
    return model.toJSON();
  }


  modelsToJSON(models) {
    return _.map(models, this.modelToJSON);
  }


  // **_validateContract** <br/>
  // @param [dataToProduce]: Object <br/>
  // The data to validate. <br/>
  // @return : Boolean
  //
  // Used to validate data against a predefined contract, if there is one.
  _validateContract(dataToProduce) {
    const { contract } = this.PRODUCTION_KEY;
    if (!contract) {
      throw new Error(`The subscriptionKey ${subscriptionKey.key} doesn't have a contract specified`);
    }

    validateContract(contract, dataToProduce, this, 'producing');
  }


  extend(obj, mixin) {
    for (let name in mixin) {
      let method = mixin[name];
      obj[name] = method;
    }
    return obj;
  }


  mixin(instance, mixin) {
    return this.extend(instance, mixin);
  }
}

_.extend(Producer.prototype, Events);

export default Producer;
