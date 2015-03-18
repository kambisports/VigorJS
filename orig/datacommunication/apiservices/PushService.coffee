define (require) ->

	PushConnection = require 'datacommunication/apiservices/utils/PushConnection'

	class PushService

		subscriptions: null
		settings: null
		_pushConnection: null


		routingKeyForParams: (params) ->
			throw "routingKeyForParams must be overridden in the subclass"


		handleMessage: (messageType, message) ->
			throw "handleMessage must be overridden in the subclass"

		isInterestedInMessage: (messageType, message) ->
			throw "isInterestedInMessage must be overridden in the subclass"

		constructor: ->
			@subscriptions = []
			PushConnection.on 'all', (messageType, message) =>
				if @isInterestedInMessage messageType, message
					@handleMessage messageType, message

		addSubscription: (subscriber) ->
			unless _.contains @subscriptions, subscriber
				@subscriptions.push subscriber

				routingKey = @routingKeyForParams subscriber.params

				shouldDoInitialFetch = not (PushConnection.hasSubscriptionForKey routingKey) and \
					_.isFunction subscriber.ready?.then
				
				if shouldDoInitialFetch
					subscriber.ready.then =>
						# check to ensure that the subscription was not removed while we
						# waited for the initial fetch
						if _.contains @subscriptions, subscriber
							PushConnection.subscribe routingKey

				else
					PushConnection.subscribe routingKey

		removeSubscription: (subscriber) ->
			if _.contains @subscriptions, subscriber
				@subscriptions = _.without @subscriptions, subscriber

				routingKey = @routingKeyForParams subscriber.params
				PushConnection.unsubscribe routingKey

	_.extend PushService.prototype, Backbone.Events

	PushService
