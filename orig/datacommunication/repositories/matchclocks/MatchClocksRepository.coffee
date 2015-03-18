define (require) ->

	ServiceRepository = require 'datacommunication/repositories/ServiceRepository'

	# services that receives data for this repo
	LiveEventsService = require 'datacommunication/apiservices/LiveEventsService'

	# the repo holds a collection of this model type
	MatchClockModel = require 'datacommunication/repositories/matchclocks/MatchClockModel'

	class MatchClocksRepository extends ServiceRepository

		model: MatchClockModel

		initialize: ->
			LiveEventsService.on LiveEventsService.MATCH_CLOCKS_RECEIVED, @_onMatchClocksReceived
			super

		_onMatchClocksReceived: (models) =>
			@set models

	return new MatchClocksRepository()