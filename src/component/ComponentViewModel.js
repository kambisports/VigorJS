import _ from 'underscore';
import {Model} from 'backbone';
import ProducerManager from 'datacommunication/ProducerManager';
import validateContract from 'utils/validateContract';

// ##ComponentViewModel
// This class is intended to be the base class for all view models in a component
//
// A ComponentViewModel handles communication with producers through the
// ProducerManager
class ComponentViewModel {
  static get extend() {
    return Model.extend;
  }
  // **constructor** <br/>
  // The constructor generates a unique id for the ViewModel that will be used to
  // handle subscriptions in the ProducerManager
  constructor() {
    this.id = `ComponentViewModel_${_.uniqueId()}`;
  }

  // **dispose** <br/>
  // Remves all subscriptions
  dispose() {
    return this.unsubscribeAll();
  }

  // **subscribe** <br/>
  // @param [key]: Object <br/>
  // A Vigor.SubscriptionKey containing a key and contract property<br/>
  // @param [callback]: Function <br/>
  // Callback function that takes care of produced data
  // @param [options]: Object (optional)<br/>
  // Pass any optional data that might be needed by a Producer
  //
  // Adds a subscription on a specific SubscriptionKey to the ProducerManager.
  // Whenever new data is produced the callback will be called with new data as param
  subscribe(key, callback, options) {
    return ProducerManager.subscribe(this.id, key, callback, options);
  }

  // **unsubscribe** <br/>
  // @param [key]: Object <br/>
  // A Vigor.SubscriptionKey containing a key and contract property<br/>
  //
  // Removes a subscription on specific key
  unsubscribe(key) {
    return ProducerManager.unsubscribe(this.id, key);
  }

  // **unsubscribeAll** <br/>
  // Removes all subscriptions
  unsubscribeAll() {
    return ProducerManager.unsubscribeAll(this.id);
  }

  // **validateContract** <br/>
  // @param [contract]: Object <br/>
  // The contract specified in the SubscriptionKey used when subscribing for data
  // @param [incommingData]: Object <br/>
  // data supplied through the subscription
  //
  // Compares contract with incomming data and checks values, types, and number
  // of properties, call this method manually from your callback if you want to
  // validate incoming data
  validateContract(contract, incommingData) {
    return validateContract(contract, incommingData, this.id);
  }
}

export default ComponentViewModel;
