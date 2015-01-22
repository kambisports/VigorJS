define (require) ->

	DataCommunicationManager = require 'datacommunication/DataCommunicationManager'

	Q = require 'lib/q'
	_ = require 'lib/underscore'

	class ViewModel

		id: 'ViewModel'
		subscriptionIds: []

		constructor: ->
			@id = @getUniqueId()

		getUniqueId: ->
			return "#{@id}_#{_.uniqueId()}"

		dispose: ->
			do @unsubscribeAll

		subscribe: (key, callback, options) ->
			return DataCommunicationManager.subscribe @id, key, callback, options

		###
		query: (key, options) ->
			return DataCommunicationManager.query key, options

		queryAndSubscribe: (queryKey, queryOptions, subscriptionKey, subscriptionCallback, subscriptionOptions) ->
			deferred = Q.defer()

			DataCommunicationManager
				.query(queryKey, queryOptions)
				.then (response) =>
					deferred.resolve response
					DataCommunicationManager.subscribe @id, subscriptionKey, subscriptionCallback, subscriptionOptions
				.catch (error) ->
					deferred.reject error

			return deferred.promise
		###

		unsubscribe: (key) ->
			return DataCommunicationManager.unsubscribe @id, key

		unsubscribeAll: ->
			return DataCommunicationManager.unsubscribeAll @id

	return ViewModel