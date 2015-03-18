define (require) ->
	
	PushService = require 'datacommunication/apiservices/PushService'

	PushConnection = require 'datacommunication/apiservices/utils/PushConnection'

	

	pushService = undefined
	

	describe 'A PushService', ->

		beforeEach ->
			spyOn PushConnection, 'on'
			pushService = new PushService

		it 'adds a subscription', ->
			subscription = {}
			routingKey = 'foo'
			
			spyOn PushConnection, 'subscribe'
			(spyOn PushConnection, 'hasSubscriptionForKey').andReturn false
			(spyOn pushService, 'routingKeyForParams').andReturn routingKey

			pushService.addSubscription subscription

			(expect PushConnection.subscribe.calls.length).toBe 1
			args = PushConnection.subscribe.calls[0].args
			(expect args.length).toBe 1
			(expect args[0]).toBe routingKey

		it 'adds subscriptions for different keys', ->
			params1 = {}
			params2 = {}
			subscription1 =
				params: params1
			subscription2 =
				params: params2
			routingKey1 = 'foo'
			routingKey2 = 'bar'

			spyOn PushConnection, 'subscribe'
			(spyOn PushConnection, 'hasSubscriptionForKey').andReturn false
			(spyOn pushService, 'routingKeyForParams').andCallFake (params) ->
				switch params
					when params1 then routingKey1
					when params2 then routingKey2
					else ''

			pushService.addSubscription subscription1
			pushService.addSubscription subscription2

			(expect PushConnection.subscribe.calls.length).toBe 2
			args1 = PushConnection.subscribe.calls[0].args
			args2 = PushConnection.subscribe.calls[1].args
			(expect args1.length).toBe 1
			(expect args2.length).toBe 1
			(expect args1[0]).toBe routingKey1
			(expect args2[0]).toBe routingKey2

		it 'adds a subscription even if the connection already has a subscription for that key', ->
			subscription = {}
			routingKey = 'foo'
			
			spyOn PushConnection, 'subscribe'
			(spyOn PushConnection, 'hasSubscriptionForKey').andReturn true
			(spyOn pushService, 'routingKeyForParams').andReturn routingKey

			pushService.addSubscription subscription

			(expect PushConnection.subscribe.calls.length).toBe 1
			args = PushConnection.subscribe.calls[0].args
			(expect args.length).toBe 1
			(expect args[0]).toBe routingKey

		it 'does not add a subscription if the subscription has already been added', ->
			subscription = {}
			routingKey = 'foo'
			
			spyOn PushConnection, 'subscribe'
			(spyOn PushConnection, 'hasSubscriptionForKey').andReturn false
			(spyOn pushService, 'routingKeyForParams').andReturn routingKey

			pushService.addSubscription subscription
			pushService.addSubscription subscription

			(expect PushConnection.subscribe.calls.length).toBe 1
			args = PushConnection.subscribe.calls[0].args
			(expect args.length).toBe 1
			(expect args[0]).toBe routingKey

		it 'does not add a subscription immediately if the subscriber has a ready promise', ->
			subscription =
				ready:
					then: jasmine.createSpy()

			routingKey = 'foo'
			
			spyOn PushConnection, 'subscribe'
			(spyOn PushConnection, 'hasSubscriptionForKey').andReturn false
			(spyOn pushService, 'routingKeyForParams').andReturn routingKey

			pushService.addSubscription subscription

			(expect PushConnection.subscribe.calls.length).toBe 0

		it 'does not add a subscription immediately if the subscriber has a ready promise but the connection already has a subscription for that key', ->
			subscription =
				ready:
					then: jasmine.createSpy()

			routingKey = 'foo'
			
			spyOn PushConnection, 'subscribe'
			(spyOn PushConnection, 'hasSubscriptionForKey').andReturn true
			(spyOn pushService, 'routingKeyForParams').andReturn routingKey

			pushService.addSubscription subscription

			(expect PushConnection.subscribe.calls.length).toBe 1

		it 'adds a subscription when the promise resolves', ->
			subscription =
				ready:
					then: jasmine.createSpy()

			routingKey = 'foo'
			
			spyOn PushConnection, 'subscribe'
			(spyOn PushConnection, 'hasSubscriptionForKey').andReturn false
			(spyOn pushService, 'routingKeyForParams').andReturn routingKey

			pushService.addSubscription subscription

			(expect subscription.ready.then.calls.length).toBe 1
			args = subscription.ready.then.calls[0].args
			(expect args.length).toBe 1
			callback = args[0]
			(expect typeof callback).toBe 'function'
			callback()

			(expect PushConnection.subscribe.calls.length).toBe 1
			args = PushConnection.subscribe.calls[0].args
			(expect args.length).toBe 1
			(expect args[0]).toBe routingKey

		it 'removes a subscription', ->
			subscription = {}
			routingKey = 'foo'

			spyOn PushConnection, 'subscribe'
			spyOn PushConnection, 'unsubscribe'
			(spyOn PushConnection, 'hasSubscriptionForKey').andReturn false
			(spyOn pushService, 'routingKeyForParams').andReturn routingKey

			pushService.addSubscription subscription
			pushService.removeSubscription subscription

			(expect PushConnection.unsubscribe.calls.length).toBe 1
			args = PushConnection.unsubscribe.calls[0].args
			(expect args.length).toBe 1
			(expect args[0]).toBe routingKey


		it 'removes only the subscription for the relevant key', ->
			params1 = {}
			params2 = {}
			subscription1 =
				params: params1
			subscription2 =
				params: params2
			routingKey1 = 'foo'
			routingKey2 = 'bar'

			spyOn PushConnection, 'subscribe'
			spyOn PushConnection, 'unsubscribe'
			(spyOn PushConnection, 'hasSubscriptionForKey').andReturn false
			(spyOn pushService, 'routingKeyForParams').andCallFake (params) ->
				switch params
					when params1 then routingKey1
					when params2 then routingKey2
					else ''

			pushService.addSubscription subscription1
			pushService.addSubscription subscription2

			pushService.removeSubscription subscription1

			(expect PushConnection.unsubscribe.calls.length).toBe 1
			args = PushConnection.unsubscribe.calls[0].args
			(expect args.length).toBe 1
			(expect args[0]).toBe routingKey1

		it 'does not unsubscribe from the connection if the subscription was not added', ->
			subscription = {}
			routingKey = 'foo'

			spyOn PushConnection, 'unsubscribe'
			(spyOn PushConnection, 'hasSubscriptionForKey').andReturn false
			(spyOn pushService, 'routingKeyForParams').andReturn routingKey

			pushService.removeSubscription subscription

			(expect PushConnection.unsubscribe.calls.length).toBe 0


		it 'does not add a subscription when the promise resolves if the subscription was removed while waiting for the promise to resolve', ->
			subscription =
				ready:
					then: jasmine.createSpy()

			routingKey = 'foo'
			
			spyOn PushConnection, 'subscribe'
			(spyOn PushConnection, 'hasSubscriptionForKey').andReturn false
			(spyOn pushService, 'routingKeyForParams').andReturn routingKey

			pushService.addSubscription subscription
			pushService.removeSubscription subscription

			(expect subscription.ready.then.calls.length).toBe 1
			args = subscription.ready.then.calls[0].args
			(expect args.length).toBe 1
			callback = args[0]
			(expect typeof callback).toBe 'function'
			callback()

			(expect PushConnection.subscribe.calls.length).toBe 0


		it 'subscribes to events from the connection', ->
			(expect PushConnection.on.calls.length).toBe 1
			args = PushConnection.on.calls[0].args
			(expect args.length).toBe 2
			events = args[0]
			(expect events).toBe 'all'
			callback = args[1]
			(expect typeof callback).toBe 'function'

		it 'does not call handleMessage if isInterestedInMessage is false', ->
			messageType = 'foo'
			message = {}

			(spyOn pushService, 'isInterestedInMessage').andReturn false
			spyOn pushService, 'handleMessage'

			callback = PushConnection.on.calls[0].args[1]
			callback messageType, message

			(expect pushService.isInterestedInMessage.calls.length).toBe 1
			(expect pushService.handleMessage.calls.length).toBe 0

		it 'calls handleMessage if isInterestedInMessage is true', ->
			messageType = 'foo'
			message = {}

			(spyOn pushService, 'isInterestedInMessage').andReturn true
			spyOn pushService, 'handleMessage'

			callback = PushConnection.on.calls[0].args[1]
			callback messageType, message

			(expect pushService.isInterestedInMessage.calls.length).toBe 1
			(expect pushService.handleMessage.calls.length).toBe 1

			args = pushService.handleMessage.calls[0].args
			(expect args.length).toBe 2
			(expect args[0]).toBe messageType
			(expect args[1]).toBe message
