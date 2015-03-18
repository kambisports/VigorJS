define (require) ->

	ServiceRepository = require 'datacommunication/repositories/ServiceRepository'

	# services that receives data for this repo
	LiveEventsService = require 'datacommunication/apiservices/LiveEventsService'

	# the repo holds a collection of this model type
	StatisticsModel = require 'datacommunication/repositories/statistics/StatisticsModel'

	class StatisticsRepository extends ServiceRepository

		model: StatisticsModel

		initialize: ->
			LiveEventsService.on LiveEventsService.STATISTICS_RECEIVED, @_onStatisticsReceived
			super

		_onStatisticsReceived: (models) =>
			@set models

	return new StatisticsRepository()