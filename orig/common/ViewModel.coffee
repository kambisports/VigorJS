define (require) ->

	dataCommunicationManager = require 'datacommunication/DataCommunicationManager'

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

			return dataCommunicationManager.subscribe @id, key, callback, options

		unsubscribe: (key) ->
			return dataCommunicationManager.unsubscribe @id, key

		unsubscribeAll: ->
			return dataCommunicationManager.unsubscribeAll @id

	return ViewModel