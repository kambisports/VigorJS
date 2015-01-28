class EventRegistry
	constructor: ->
		_.extend @, Backbone.Events

# A global EventBus for the entire application
#
# @example How to subscribe to events
#   EventBus.subscribe EventKeys.EXAMPLE_EVENT_KEY, (event) ->
#			# do something with `event` here...
#
class EventBus
	eventRegistry: new EventRegistry()


	# Bind a `callback` function to an event key. Passing `all` as key will
	# bind the callback to all events fired.
	#
	# @param [String] the event key to subscribe to. See datacommunication/EventKeys for available keys.
	# @param [function] the callback that receives the event when it is sent
	subscribe: (key, callback) ->
		throw "key '#{key}' does not exist in EventKeys" unless @_eventKeyExists key
		throw "callback is not a function" unless 'function' == typeof callback

		@eventRegistry.on key, callback

	# Bind a callback to only be triggered a single time.
	# After the first time the callback is invoked, it will be removed.
	#
	# @param [String] the event key to subscribe to. See datacommunication/EventKeys for available keys.
	# @param [function] the callback that receives the single event when it is sent
	subscribeOnce: (key, callback) ->
		throw "key '#{key}' does not exist in EventKeys" unless @_eventKeyExists key
		throw "callback is not a function" unless 'function' == typeof callback

		@eventRegistry.once key, callback


	# Remove a callback.
	#
	# @param [String] the event key to unsubscribe from.
	# @param [Function] the callback that is to be unsubscribed
	unsubscribe: (key, callback) ->
		throw "key '#{key}' does not exist in EventKeys" unless @_eventKeyExists key
		throw "callback is not a function" unless 'function' == typeof callback

		@eventRegistry.off key, callback

	# Send an event message  to all bound callbacks. Callbacks are passed the
	# message argument, (unless you're listening on `all`, which will
	# cause your callback to receive the true name of the event as the first
	# argument).
	#
	# @param [String] the event key to send the message on.
	# @param [Object] the message to send
	send: (key, message) ->
		throw "key '#{key}' does not exist in EventKeys" unless @_eventKeyExists key

		@eventRegistry.trigger key, message

	_eventKeyExists: (key) ->
		key in (value for property, value of Vigor.EventKeys)

Vigor.EventBus = new EventBus()