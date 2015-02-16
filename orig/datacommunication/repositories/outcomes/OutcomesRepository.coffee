define (require) ->

	ServiceRepository = require 'datacommunication/repositories/ServiceRepository'

	# services that receives data for this repo
	MostPopularService = require 'datacommunication/apiservices/MostPopularService'
	LiveEventsService = require 'datacommunication/apiservices/LiveEventsService'

	# the repo holds a collection of this model type
	OutcomeModel = require 'datacommunication/repositories/outcomes/OutcomeModel'

	class OutcomesRepository extends ServiceRepository

		model: OutcomeModel
		liveOutcomes = undefined
		mostPopularOutcomes = undefined

		initialize: ->
			MostPopularService.on MostPopularService.OUTCOMES_RECEIVED, @_onMostPopularOutcomesReceived
			LiveEventsService.on LiveEventsService.EVENTS_RECEIVED, @_onLiveOutcomesReceived
			@liveOutcomes = []
			@mostPopularOutcomes = []
			super

		getOutcomesByBetofferId: (betofferId) ->
			@where {'betofferId' : betofferId}

		getLiveOutcomes: ->
			return @liveOutcomes

		getMostPopularOutcomes: ->
			return @mostPopularOutcomes

		getPopularOutcomes: ->
			return @where 'popular': true


		_onLiveOutcomesReceived: (models) =>
			liveOutcomeIds = _.map models, (model) ->
				return model.id
			@set models, { remove: false }
			@liveOutcomes = @getByIds liveOutcomeIds

		_onMostPopularOutcomesReceived: (models) =>
			mostPopularOutcomeIds = _.map models, (model) ->
				return model.id
			@set models, { remove: false }
			@mostPopularOutcomes = @getByIds mostPopularOutcomeIds

		makeTestInstance: () ->
			new OutcomesRepository()

	return new OutcomesRepository()