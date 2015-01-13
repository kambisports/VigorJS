define (require) ->

	Q = require 'lib/q'
	Producer = require 'datacommunication/producers/Producer'

	QueryKeys = require 'datacommunication/QueryKeys'
	SubscriptionKeys = require 'datacommunication/SubscriptionKeys'

	# Collections needed to build/produce data
	EventsRepository = require 'datacommunication/repositories/events/EventsRepository'

	class EventProducer extends Producer

		constructor: ->
			super
			do @addRespositoryListeners

		dispose: ->
			do @removeRespositoryListeners
			super

		addRespositoryListeners: () ->
			EventsRepository.on 'change', @onEventChangedInCollection, @

		removeRespositoryListeners: () ->
			EventsRepository.off 'change', @onEventChangedInCollection, @

		query: (queryKey, options) ->
			deferred = Q.defer()
			switch queryKey
				when QueryKeys.EVENT
					EventsRepository.queryEvent(options).then (data) =>
						deferred.resolve @buildData data
					return deferred.promise
				else
					throw new Error("Unknown query queryKey: #{queryKey}")

		# Handlers
		onEventChangedInCollection: (eventModel) =>
			@produce SubscriptionKeys.EVENT_CHANGE, eventModel.toJSON(), (componentOptions) ->
				eventModel.get('id') is componentOptions.eventId

		buildData: (data) ->
			groupPath = _.pluck data.get('path'), 'name'

			jsonData = do data.toJSON
			jsonData.group = _.reduce groupPath, (memo, name) ->
				"#{memo} / #{name}"

			jsonData.url = "#event/#{jsonData.id}"

			return jsonData


		SUBSCRIPTION_KEYS : [SubscriptionKeys.EVENT_CHANGE]
		QUERY_KEYS: [QueryKeys.EVENT]

		NAME : 'EventProducer'
