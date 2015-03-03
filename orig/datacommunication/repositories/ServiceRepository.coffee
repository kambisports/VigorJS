define (require) ->

	_ = require 'lib/underscore'
	Repository = require './Repository'

	class ServiceRepository extends Repository

		addSubscription: (type, subscription) ->
			if @services[type]
				@services[type].addSubscription subscription

		removeSubscription: (type, subscription) ->
			if @services[type]
				@services[type].removeSubscription subscription

	ServiceRepository
