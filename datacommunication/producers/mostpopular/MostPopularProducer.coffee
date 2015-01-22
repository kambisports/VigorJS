define (require) ->

	_ = require 'lib/underscore'
	ApplicationSettingsModel = require 'datacommunication/models/ApplicationSettingsModel'
	StringUtil = require 'utils/StringUtil'
	Producer = require 'datacommunication/producers/Producer'

	SubscriptionKeys = require 'datacommunication/SubscriptionKeys'

	# Collections needed to build/produce data
	MostPopularRepository = require 'datacommunication/repositories/mostpopular/MostPopularRepository'

	DefaultStakes = require './DefaultStakes'

	class MostPopularProducer extends Producer

		_debouncedOnRepositoryAdd: undefined
		_debouncedOnRepositoryChange: undefined
		_debouncedOnRepositoryRemove: undefined

		constructor: ->
			@_debouncedOnRepositoryAdd = _.debounce @_onChangesInRepository, 0
			@_debouncedOnRepositoryChange = _.debounce @_onChangesInRepository, 0
			@_debouncedOnRepositoryRemove = _.debounce @_onChangesInRepository, 0

			MostPopularRepository.on 'reset', @_onResetInRepository, @

			# Most popular doesn't subscribe to changes ATM
			#MostPopularRepository.on 'add', @_debouncedOnRepositoryAdd, @
			#MostPopularRepository.on 'change', @_debouncedOnRepositoryChange, @
			#MostPopularRepository.on 'remove', @_debouncedOnRepositoryRemove, @
			super

		dispose: ->
			MostPopularRepository.off 'reset', @_onResetInRepository, @
			MostPopularRepository.off 'add', @_debouncedOnRepositoryAdd, @
			MostPopularRepository.off 'change', @_debouncedOnRepositoryChange, @
			MostPopularRepository.off 'remove', @_debouncedOnRepositoryRemove, @

			@_debouncedOnRepositoryAdd = undefined
			@_debouncedOnRepositoryChange = undefined
			@_debouncedOnRepositoryRemove = undefined

			MostPopularRepository.notInterestedInUpdates @NAME

		subscribe: (subscriptionKey, options) ->
			MostPopularRepository.interestedInUpdates @NAME

			switch subscriptionKey
				when SubscriptionKeys.NEW_MOST_POPULAR_EVENTS
					models = MostPopularRepository.queryBetoffers options
					if models.length > 0 then @_produceData models
				else
					throw new Error("Unknown query subscriptionKey: #{subscriptionKey}")

		# Builders
		buildData: (data) ->
			formattedData = {}
			currency = ApplicationSettingsModel.get 'currency'
			currencyKey = "#{StringUtil.toUpperCase(currency)}_CURRENCY_DEFAULT_STAKES"

			formattedData.events = _.map data, (mostPopModel) ->
				eventId: mostPopModel.get 'eventId'
				betofferId: mostPopModel.get 'betofferId'

			formattedData.selectedOutcomes = _.map data, (mostPopModel) ->
				outcomeId: mostPopModel.get 'outcomeId'
				odds: mostPopModel.get 'outcomeOdds'

			formattedData.defaultStakes = DefaultStakes[currencyKey]

			return formattedData

		_produceData: (models) ->
			producedData = @buildData models
			@produce SubscriptionKeys.NEW_MOST_POPULAR_EVENTS, producedData, ->

		# Handlers
		_onResetInRepository: (collection) ->
			@_produceData collection.models

		_onChangesInRepository: () ->
			@_produceData MostPopularRepository.models

		SUBSCRIPTION_KEYS : [SubscriptionKeys.NEW_MOST_POPULAR_EVENTS]

		NAME : 'MostPopularProducer'
