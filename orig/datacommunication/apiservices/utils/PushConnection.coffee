define (require) ->

	Backbone = require 'lib/backbone'
	SocketIO = require 'model/push/clients/SocketIO'

	pako = require 'lib/pako_inflate'

	class PushConnection

		constructor: (@_window = window) ->
			@subscriptions = {}
			@pushClient = undefined

			@customerName = @_window._kc.customer
			@pushUrl = @_window._kc.pushUrl
			@language = (@_window._kc.locale.split '_')[0]

		decorateKey: (key) ->
			"#{@customerName}.#{key}.json"

		decorateLocalizedKey: (key) ->
			"#{@customerName}.#{@language}.#{key}.json"

		subscribe: (key) ->
			unless @pushClient
				@connect()

			subscriptionCount = @subscriptions[key]

			unless subscriptionCount
				@subscriptions[key] = 0
				@pushClient.subscribe @decorateKey key
				@pushClient.subscribe @decorateLocalizedKey key

			@subscriptions[key] += 1

		unsubscribe: (key) ->
			if @subscriptions[key] > 0
				@subscriptions[key] -= 1

			if @subscriptions[key] is 0
				@pushClient.unsubscribe @decorateKey key
				@pushClient.unsubscribe @decorateLocalizedKey key

		hasSubscriptionForKey: (key) ->
			@subscriptions[key] > 0
		
		connect: ->
			# TODO: hook up logging for the connection
			@pushClient = SocketIO.getConnection @pushUrl

			@pushClient.on @pushClient.EVENT_MESSAGE, @_onPushMessage, @
			@pushClient.on @pushClient.EVENT_PUSH_RECONNECTED, @_resubscribe, @

			@pushClient.connect()

			document = @_window.document
			if (typeof document.hidden != "undefined")
				@_hidden = "hidden"
				@_visibilityChange = "visibilitychange"
			else if (typeof document.mozHidden != "undefined")
				@_hidden = "mozHidden"
				@_visibilityChange = "mozvisibilitychange"
			else if (typeof document.msHidden != "undefined")
				@_hidden = "msHidden"
				@_visibilityChange = "msvisibilitychange"
			else if (typeof document.webkitHidden != "undefined")
				@_hidden = "webkitHidden"
				@_visibilityChange = "webkitvisibilitychange"

			document.addEventListener @_visibilityChange, (_.bind @_handleVisibilityChange, @), false

		_handleVisibilityChange: ->
			unless (@_window.document[@_hidden])
				@_resubscribe()

		_resubscribe: ->
			_.each @subscriptions, (val, key) ->
				if val > 0
					@pushClient.subscribe @decorateKey key
					@pushClient.subscribe @decorateLocalizedKey key
			, @

		_onPushMessage: (message) ->
			compressedBuffer = atob message

			uncompressed = pako.inflate compressedBuffer,
				to: 'string'

			message = JSON.parse uncompressed.toString 'utf8'

			if message instanceof Array
				@_sendPushMessage pMessage for pMessage in message
			else
				@_sendPushMessage message

		_sendPushMessage: (message) ->
			@trigger message.mt, message

	_.extend PushConnection.prototype, Backbone.Events

	new PushConnection()