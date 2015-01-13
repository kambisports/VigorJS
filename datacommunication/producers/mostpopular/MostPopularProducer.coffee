define (require) ->

	Q = require 'lib/q'
	Producer = require 'datacommunication/producers/Producer'

	QueryKeys = require 'datacommunication/QueryKeys'
	SubscriptionKeys = require 'datacommunication/SubscriptionKeys'

	# Collections needed to build/produce data
	MostPopularRepository = require 'datacommunication/repositories/mostpopular/MostPopularRepository'

	DefaultStakes = require './DefaultStakes'

	class MostPopularProducer extends Producer

		constructor: ->
			MostPopularRepository.on 'change', @_onChange, @
			super

		dispose: ->
			MostPopularRepository.off 'change', @_onChange
			MostPopularRepository.notInterestedInUpdates @NAME


		subscribe: (subscriptionKey, options) ->
			MostPopularRepository.interestedInUpdates @NAME


		# (queryKey, options) is the known format
		query: (queryKey) ->
			deferred = Q.defer()
			switch queryKey
				when QueryKeys.MOST_POPULAR_EVENTS
					MostPopularRepository.queryBetoffers().then (data) =>
						deferred.resolve @buildData(data)
					return deferred.promise
				else
					throw new Error("Unknown query queryKey: #{queryKey}")

		# Builders
		buildData: (data) ->
			formattedData = {}
			formattedData.events = _.map data, (mostPopModel) ->
				eventId: mostPopModel.get 'eventId'
				betofferId: mostPopModel.get 'betofferId'

			formattedData.selectedOutcomes = _.map data, (mostPopModel) ->
				outcomeId: mostPopModel.get 'outcomeId'
				odds: mostPopModel.get 'outcomeOdds'

			# TODO: THIS SHOULD NOT BE HARDCODED, SHOULD GET THE CURRENCY FROM APP MODEL
			formattedData.defaultStakes = DefaultStakes['EUR_CURRENCY_DEFAULT_STAKES']

			return formattedData


		_onChange: (model) ->
			producedData = @buildData [model]
			@produce SubscriptionKeys.NEW_MOST_POPULAR_EVENTS, producedData, ->


		SUBSCRIPTION_KEYS : [SubscriptionKeys.NEW_MOST_POPULAR_EVENTS]
		QUERY_KEYS: [QueryKeys.MOST_POPULAR_EVENTS]

		NAME : 'MostPopularProducer'
