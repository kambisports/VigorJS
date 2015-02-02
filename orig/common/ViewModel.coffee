define (require) ->

	DataCommunicationManager = require 'datacommunication/DataCommunicationManager'

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

		unsubscribe: (key) ->
			return DataCommunicationManager.unsubscribe @id, key

		unsubscribeAll: ->
			return DataCommunicationManager.unsubscribeAll @id

	return ViewModel