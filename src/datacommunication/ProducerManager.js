import ProducerMapper from 'datacommunication/ProducerMapper';
import Subscription from 'datacommunication/Subscription';

//  ## ProducerManager
// The ProducerManager utilizies the [ProducerMapper](ProducerMapper.html) to (un)register components on subscriptions.
//
const ProducerManager = {

  // **registerProducers:** </br>
  // @param [producers]: Array <br/>
  //
  // Registers a one or more producers in mapper
  registerProducers(producers) {
    producers.forEach(producer => ProducerMapper.register(producer));
  },

  // **producerForKey:** </br>
  // @param [subscriptionKey]: String <br/>
  // @returns [producer]: Producer </br>
  //
  // Retrieves a registered producer for the given subscription
  producerForKey(subscriptionKey) {
    return ProducerMapper.producerForKey(subscriptionKey);
  },

  // **subscribe:** </br>
  // @param [componentId]: String <br/>
  // @param [subscriptionKey]: Object <br/>
  // @param [callback]: Function <br/>
  // @param [subscriptionOptions]: Object (default empty object) <br/>
  //
  // Registers a component with [componentId] to recieve data changes on given [subscriptionKey] through the component [callback]
  subscribe(componentId, subscriptionKey, callback, subscriptionOptions = {}) {
    const subscription = new Subscription(componentId, callback, subscriptionOptions);
    const producer = this.producerForKey(subscriptionKey);
    producer.addComponent(subscription);
  },

  // **unsubscribe:** </br>
  // @param [componentId]: String <br/>
  // @param [subscriptionKey]: String <br/>
  //
  // Unsubscribes a component with [componentId] from the producer for the given [subscriptionKey]
  unsubscribe(componentId, subscriptionKey) {
    const producer = this.producerForKey(subscriptionKey);
    producer.removeComponent(componentId);
  },

  // **unsubscribeAll:** </br>
  // @param [componentId]: String <br/>
  //
  // Unsubscribes a component with [componentId] from any producer that might have it in its subscription
  unsubscribeAll(componentId) {
    ProducerMapper.producers.forEach(producer => producer.prototype.getInstance().removeComponent(componentId));
  }
};

export default ProducerManager;
