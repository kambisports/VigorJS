import Repository from 'datacommunication/repositories/Repository';
//  ## ServiceRepository
//
// A ServiceRepository extends the Repository class and enables
// subscriptions for services
//

class ServiceRepository extends Repository {

  get services() {
    return this._services || {};
  }

  set services(services) {
    this._services = services;
  }

  // **addSubscriptionToService** <br/>
  // @param [service]: Object <br/>
  // The service to add the subscription to </br>
  // @param [subscription]: Object <br/>
  // The subscription to add to the service
  //
  // Adds a subscription to a service
  addSubscriptionToService(service, subscription) {
    service.addSubscription(subscription);
  }

  // **removeSubscriptionFromService** <br/>
  // @param [service]: Object <br/>
  // The service to remove the subscription from </br>
  // @param [subscription]: Object <br/>
  // The subscription to remove from the service
  //
  // Removes a subscription from a service
  removeSubscriptionFromService(service, subscription) {
    service.removeSubscription(subscription);
  }

  // **addSubscription** <br/>
  // @param [type]: String <br/>
  // Used to identify the service for this subscription.
  // @param [subscription]: Object <br/>
  // Used to configure the service request
  //
  // Maps the service through type before subscribing
  addSubscription(type, subscription) {
    if (this.services[type]) {
      this.addSubscriptionToService(this.services[type], subscription);
    }
  }

  // **removeSubscription** <br/>
  // @param [type]: String <br/>
  // Used to identify the service for this subscription.
  // @param [subscription]: Object <br/>
  // Used to configure the service request
  //
  // Maps the service through type before unsubscribing
  removeSubscription(type, subscription) {
    if (this.services[type]) {
      this.removeSubscriptionFromService(this.services[type], subscription);
    }
  }
}

// Expose ServiceRepository on the Vigor object
export default ServiceRepository;