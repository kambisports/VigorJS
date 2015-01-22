define (require) ->

	_ = require 'lib/underscore'
	Producer = require 'datacommunication/producers/Producer'

	SubscriptionKeys = require 'datacommunication/SubscriptionKeys'

	# Collections needed to build/produce data
	EventsRepository = require 'datacommunication/repositories/events/EventsRepository'

	class EventProducer extends Producer

		_debouncedOnRepositoryChange: undefined

		constructor: ->
			@_debouncedOnRepositoryChange = _.debounce @_onChangesInRepository, 0
			EventsRepository.on 'change', @_debouncedOnRepositoryChange, @

			EventsRepository.on 'reset', @_onResetInRepository, @
			super

		dispose: ->
			EventsRepository.off 'change', @_debouncedOnRepositoryChange, @
			_debouncedOnRepositoryChange = undefined

			EventsRepository.off 'reset', @_onResetInRepository, @
			super

		subscribe: (subscriptionKey, options) ->
			switch subscriptionKey
				when SubscriptionKeys.EVENT_CHANGE
					eventModel = EventsRepository.queryEvent options
					if eventModel
						@_produceData eventModel
				else
					throw new Error("Unknown subscription subscriptionKey: #{subscriptionKey}")

		# Handlers
		_onResetInRepository: (collection) ->
			window.console.log 'EventProducer:_onResetInRepository'

		_onChangesInRepository: (eventModel) =>
			@_produceData eventModel

		_buildData: (data) ->
			groupPath = _.pluck data.get('path'), 'name'

			jsonData = do data.toJSON
			jsonData.group = _.reduce groupPath, (memo, name) ->
				"#{memo} / #{name}"

			jsonData.url = "#event/#{jsonData.id}"

			return jsonData

		_produceData: (eventModel) ->
			eventJson = @_buildData eventModel
			@produce SubscriptionKeys.EVENT_CHANGE, eventJson, (componentOptions) ->
				eventJson.id is componentOptions.eventId

		SUBSCRIPTION_KEYS : [SubscriptionKeys.EVENT_CHANGE]

		NAME : 'EventProducer'
