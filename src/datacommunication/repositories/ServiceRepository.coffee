#  ## ServiceRepository
# 
# A ServiceRepository extends the Repository class and enables
# subscriptions for services
#

class ServiceRepository extends Vigor.Repository

  # Holds the services
  services: {}

  # **addSubscriptionToService** <br/>
  # @param [service]: Object <br/>
  # The service to add the subscription to </br>
  # @param [subscription]: Object <br/>
  # The subscription to add to the service
  #
  # Adds a subscription to a service
  addSubscriptionToService: (service, subscription) ->
    service.addSubscription subscription

  # **removeSubscriptionFromService** <br/>
  # @param [service]: Object <br/>
  # The service to remove the subscription from </br>
  # @param [subscription]: Object <br/>
  # The subscription to remove from the service
  #
  # Removes a subscription from a service
  removeSubscriptionFromService: (service, subscription) ->
    service.removeSubscription subscription

  # **addSubscription** <br/>
  # @param [type]: String <br/>
  # The type of service(s) to add the subscription for </br>
  # @param [subscription]: Object <br/>
  #
  # Adds a subscription to service(s) of a certain type
  addSubscription: (type, subscription) ->
    if @services[type]
      @addSubscriptionToService @services[type], subscription

  # **removeSubscription** <br/>
  # @param [type]: String <br/>
  # The type of service(s) to remove the subscription for </br>
  # @param [subscription]: Object <br/>
  #
  # Removes a subscription from service(s) of a certain type
  removeSubscription: (type, subscription) ->
    if @services[type]
      @removeSubscriptionFromService @services[type], subscription

# Expose ServiceRepository on the Vigor object
Vigor.ServiceRepository = ServiceRepository