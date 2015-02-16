define (require) ->

	ServiceRepository = require 'datacommunication/repositories/ServiceRepository'

	# services that receives data for this repo
	MostPopularService = require 'datacommunication/apiservices/MostPopularService'
	LiveEventsService = require 'datacommunication/apiservices/LiveEventsService'

	# The repo holds a collection of this model type
	BetofferModel = require 'datacommunication/repositories/betoffers/BetofferModel'

	class BetoffersRepository extends ServiceRepository

		model: BetofferModel
		liveBetofferIds: undefined
		mostPopularBetofferIds: undefined

		initialize: ->
			MostPopularService.on MostPopularService.BETOFFERS_RECEIVED, @_onMostPopularBetoffersReceived
			LiveEventsService.on LiveEventsService.BETOFFERS_RECEIVED, @_onLiveBetoffersReceived
			@liveBetoffers = []
			@mostPopularBetoffers = []
			super

		fetchBetoffer: (options) ->
			@callApiService LiveEventsService.NAME, options
			return @getBetoffer(options.betofferId)

		getBetoffer: (id) ->
			return @findWhere('id': id)

		getMostPopularBetoffers: ->
			return @mostPopularBetoffers

		_onLiveBetoffersReceived: (models) =>
			liveBetofferIds = _.map models, (model) ->
				return model.id
			@set models, { remove: false }
			@liveBetoffers = @getByIds liveBetofferIds

		_onMostPopularBetoffersReceived: (models) =>
			mostPopularBetofferIds = _.map models, (model) ->
				return model.id
			@set models, { remove: false }
			@mostPopularBetoffers = @getByIds mostPopularBetofferIds


		makeTestInstance: ->
			new BetoffersRepository()

	return new BetoffersRepository()