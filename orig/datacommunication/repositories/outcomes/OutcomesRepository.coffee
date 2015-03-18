define (require) ->

	ServiceRepository = require 'datacommunication/repositories/ServiceRepository'

	# services that receives data for this repo
	MostPopularService = require 'datacommunication/apiservices/MostPopularService'
	LiveEventsService = require 'datacommunication/apiservices/LiveEventsService'
	OutcomeOddsService = require 'datacommunication/apiservices/OutcomeOddsService'

	# the repo holds a collection of this model type
	OutcomeModel = require 'datacommunication/repositories/outcomes/OutcomeModel'

	class OutcomesRepository extends ServiceRepository

		model: OutcomeModel
		liveOutcomes = undefined
		mostPopularOutcomes = undefined

		LIVE: 'live'
		MOST_POPULAR: 'most_popular'
		OUTCOME_ODDS: 'outcome_odds'

		services:
			'live': LiveEventsService
			'most_popular': MostPopularService
			'outcome_odds': OutcomeOddsService

		initialize: ->
			MostPopularService.on MostPopularService.OUTCOMES_RECEIVED, @_onMostPopularOutcomesReceived
			LiveEventsService.on LiveEventsService.OUTCOMES_RECEIVED, @_onLiveOutcomesReceived
			OutcomeOddsService.on OutcomeOddsService.OUTCOMES_RECEIVED, @_onOutcomesReceived
			@liveOutcomes = []
			@mostPopularOutcomes = []
			super

		getOutcomesByBetofferId: (betofferId) ->
			@where { 'betofferId' : betofferId }

		getLiveOutcomes: ->
			return @liveOutcomes

		getMostPopularOutcomes: ->
			return @mostPopularOutcomes

		getPopularOutcomes: ->
			return @where 'popular': true

		_onOutcomesReceived: (models) =>
			@set models, { remove: false }

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

	return new OutcomesRepository()