define (require) ->

	_ = require 'lib/underscore'
	
	SocketIO = require 'model/push/clients/SocketIO'
	PushConnection = require 'datacommunication/apiservices/utils/PushConnection'

	# utility functions
	callArgs = (call) -> call.args
	argsOf = (calls) -> _.map calls, callArgs

	callback = (args) -> args[1]
	callbacksFor = (args) -> _.map args, callback

	boundCallback = (args) -> _.bind args[1], args[2]
	boundCallbacksFor = (args) -> _.map args, boundCallback

	invoke = (f) -> f()
	invokeAll = (fs) -> _.each fs, invoke

	# spec-specific utilities
	expectedNonLocalizedDecoratedKey = (key) ->
		"#{windowStub._kc.customer}.#{key}.json"

	expectedLocalizedDecoratedKey = (key) ->
		"#{windowStub._kc.customer}.#{(windowStub._kc.locale.split '_')[0]}.#{key}.json"


	createWindowStub = ->
		document:
			hidden: false
			addEventListener: jasmine.createSpy 'addEventListener'
		_kc:
			customer: 'customerStub'
			pushUrl: 'pushUrlStub'
			locale: 'langStub_locStub'

	windowStub = undefined
	pushConnection = undefined
	socketConnection = undefined

	EVENT_MESSAGE = 'message'
	EVENT_PUSH_RECONNECTED = 'reconnect'



	describe 'A PushConnection', ->

		beforeEach ->
			windowStub = createWindowStub()
			pushConnection = new PushConnection.constructor windowStub
			socketConnection = jasmine.createSpyObj '', ['connect', 'on', 'subscribe', 'unsubscribe']
			socketConnection.EVENT_MESSAGE = EVENT_MESSAGE
			socketConnection.EVENT_PUSH_RECONNECTED = EVENT_PUSH_RECONNECTED

			(spyOn SocketIO, 'getConnection').andCallFake ->
				socketConnection

		describe 'defines push routing keys', ->
			it 'defines the non-localized key', ->
				key = 'foo'
				decoratedKey = pushConnection.decorateKey key
				(expect decoratedKey).toBe expectedNonLocalizedDecoratedKey key

			it 'defines the localized key', ->
				key = 'foo'
				decoratedKey = pushConnection.decorateLocalizedKey key
				(expect decoratedKey).toBe expectedLocalizedDecoratedKey key

		it 'sets up a connection on first subscription', ->
			key = 'foo'
			pushConnection.subscribe key
			
			(expect SocketIO.getConnection.calls.length).toBe 1
			getConnectionArgs = SocketIO.getConnection.mostRecentCall.args
			(expect getConnectionArgs.length).toBe 1
			(expect getConnectionArgs[0]).toBe windowStub._kc.pushUrl

			(expect socketConnection.connect.calls.length).toBe 1

			(expect socketConnection.subscribe.calls.length).toBe 2

			args = _.map socketConnection.subscribe.calls, (call) ->
				call.args

			_.each args, (args) ->
				(expect args.length).toBe 1

			args = _.flatten args

			expectedArgs = [
				expectedNonLocalizedDecoratedKey key
				expectedLocalizedDecoratedKey key
			]

			_.each expectedArgs, (arg) ->
				(expect args.indexOf arg).not.toBe -1

		it 'does not connect more than once', ->
			key1 = 'foo'
			key2 = 'bar'

			pushConnection.subscribe key1
			(expect SocketIO.getConnection.calls.length).toBe 1

			pushConnection.subscribe key2
			(expect SocketIO.getConnection.calls.length).toBe 1

		it 'subscribes with a second key', ->
			key1 = 'foo'
			key2 = 'bar'

			pushConnection.subscribe key1
			pushConnection.subscribe key2

			(expect socketConnection.subscribe.calls.length).toBe 4

			args = _.map socketConnection.subscribe.calls, (call) ->
				call.args

			_.each args, (args) ->
				(expect args.length).toBe 1

			args = _.flatten args

			expectedArgs = [
				expectedNonLocalizedDecoratedKey key1
				expectedNonLocalizedDecoratedKey key2
				expectedLocalizedDecoratedKey key1
				expectedLocalizedDecoratedKey key2
			]

			_.each expectedArgs, (arg) ->
				(expect args.indexOf arg).not.toBe -1

		it 'does not subscribe more than once when given the same key', ->
			key = 'foo'
			
			pushConnection.subscribe key

			pushConnection.subscribe key
			(expect socketConnection.subscribe.calls.length).toBe 2

		it 'unsubscribes from a key', ->
			key = 'foo'
			
			pushConnection.subscribe key

			pushConnection.unsubscribe key
			(expect socketConnection.unsubscribe.calls.length).toBe 2

			args = _.map socketConnection.unsubscribe.calls, (call) ->
				call.args

			_.each args, (args) ->
				(expect args.length).toBe 1

			args = _.flatten args

			expectedArgs = [
				expectedNonLocalizedDecoratedKey key
				expectedLocalizedDecoratedKey key
			]

			_.each expectedArgs, (arg) ->
				(expect args.indexOf arg).not.toBe -1

		it 'does not unsubscribe from a key if it was subscribed to twice', ->
			key = 'foo'
			
			pushConnection.subscribe key
			pushConnection.subscribe key
			(expect socketConnection.subscribe.calls.length).toBe 2

			pushConnection.unsubscribe key
			(expect socketConnection.unsubscribe.calls.length).toBe 0

		it 'resubscribes on push reconnect', ->
			key = 'foo'
			
			pushConnection.subscribe key

			isReconnectCall = (args) -> args[0] is EVENT_PUSH_RECONNECTED
			reconnectListener = (args) -> _.filter args, isReconnectCall
			
			invokeAll boundCallbacksFor reconnectListener argsOf socketConnection.on.calls
			
			(expect socketConnection.subscribe.calls.length).toBe 4

		it 'resubscribes on page visibility change', ->
			key = 'foo'
			
			pushConnection.subscribe key

			isVisibilityChange = (args) -> args[0] is 'visibilitychange'
			visibilityChangeListener = (args) -> _.filter args, isVisibilityChange

			addEventListener = windowStub.document.addEventListener
			
			invokeAll callbacksFor visibilityChangeListener argsOf addEventListener.calls
			
			(expect socketConnection.subscribe.calls.length).toBe 4

		it 'does not resubscribe on page visibility change if the page is hidden', ->

			key = 'foo'
						
			pushConnection.subscribe key

			isVisibilityChange = (args) -> args[0] is 'visibilitychange'
			visibilityChangeListener = (args) -> _.filter args, isVisibilityChange

			addEventListener = windowStub.document.addEventListener

			windowStub.document.hidden = true
			invokeAll callbacksFor visibilityChangeListener argsOf addEventListener.calls
			
			(expect socketConnection.subscribe.calls.length).toBe 2