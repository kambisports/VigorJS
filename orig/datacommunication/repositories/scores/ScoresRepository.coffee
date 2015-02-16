define (require) ->

	ServiceRepository = require 'datacommunication/repositories/ServiceRepository'

	# services that receives data for this repo
	LiveEventsService = require 'datacommunication/apiservices/LiveEventsService'

	# the repo holds a collection of this model type
	ScoreModel = require 'datacommunication/repositories/scores/ScoreModel'

	class ScoresRepository extends ServiceRepository

		model: ScoreModel

		initialize: ->
			LiveEventsService.on LiveEventsService.SCORES_RECEIVED, @_onScoresReceived
			super

		_onScoresReceived: (models) =>
			@set models

		makeTestInstance: () ->
			new ScoresRepository()

	return new ScoresRepository()