class ServiceRepository extends Vigor.Repository

  services: {}

  addSubscription: (type, subscription) ->
    if @services[type]
      @services[type].addSubscription subscription

  removeSubscription: (type, subscription) ->
    if @services[type]
      @services[type].removeSubscription subscription

Vigor.ServiceRepository = ServiceRepository