define (require) ->

	_ = require 'lib/underscore'
	Repository = require './Repository'

	class ServiceRepository extends Repository

		addSubscriptionToService: (service, subscription) ->
			service.addSubscription subscription

		removeSubscriptionFromService: (service, subscription) ->
			service.removeSubscription subscription

		addSubscription: (type, subscription) ->
			if @services[type]
				@addSubscriptionToService @services[type], subscription

		removeSubscription: (type, subscription) ->
			if @services[type]
				@removeSubscriptionFromService @services[type], subscription

	ServiceRepository
