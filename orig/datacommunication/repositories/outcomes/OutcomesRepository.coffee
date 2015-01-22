define (require) ->

	Q = require 'lib/q'
	Repository = require 'datacommunication/repositories/Repository'
	OutcomeModel = require 'datacommunication/repositories/outcomes/OutcomeModel'

	class OutcomesRepository extends Repository

		model: OutcomeModel

		findOutcomesByBetofferId: (betofferId) ->
			@where {'betofferId' : betofferId}

		makeTestInstance: () ->
			new OutcomesRepository()

	return new OutcomesRepository()