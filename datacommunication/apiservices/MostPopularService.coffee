define (require) ->

	ApiService = require 'datacommunication/apiservices/ApiService'

	# this resource defines if this service should poll / fetch data
	MostPopularRepository = require 'datacommunication/repositories/mostpopular/MostPopularRepository'

	# Model used for the collection that this service operates on
	MostPopopularModel = require 'datacommunication/repositories/mostpopular/MostPopularModel'

	# Repositories needed for this service (service returns events, betoffers with outcomes)
	EventsRepository = require 'datacommunication/repositories/events/EventsRepository'
	BetoffersRepository = require 'datacommunication/repositories/betoffers/BetoffersRepository'
	OutcomesRepository = require 'datacommunication/repositories/outcomes/OutcomesRepository'

	class MostPopularService extends ApiService

		prefetchDataKey: 'prefetched3way'

		constructor: (mostPopularRepository) ->
			super mostPopularRepository

		parse: (response) ->
			super response

			# Set the data in our repositories so that components later on can request (query) that data
			@_parseEvents response.events
			@_parseBetoffers response.betoffers

			# Update the most popular collection and trigger event
			@_buildMostPopularRepositoryModels response

		# Helper to update the EventsRepository
		_parseEvents: (eventObjs) ->
			EventsRepository.set eventObjs

		# Helper to set betoffers and outcomes in corresponding store
		_parseBetoffers: (betofferObjs) ->
			betoffers = []
			outcomes = []

			betoffers = _.map betofferObjs, (betoffer) ->
				betoffer.betofferType = betoffer.betOfferType
				delete betoffer.betOfferType
				_.omit betoffer, 'outcomes'

			outcomes = _.map _.flatten(_.pluck(betofferObjs, 'outcomes')), (outcome) ->
				outcome.betofferId = outcome.betOfferId
				delete outcome.betOfferId
				return outcome

			BetoffersRepository.set betoffers
			OutcomesRepository.set outcomes

		# Update the collection related to his service
		_buildMostPopularRepositoryModels: (response) ->
			@repository.set _.map response.betoffers, (betoffer) ->
				new MostPopopularModel
					id: betoffer.eventId + betoffer.id # avoid removing / adding models on every poll
					eventId: betoffer.eventId
					betofferId: betoffer.id
					outcomeId: (_.findWhere betoffer.outcomes, { popular: true }).id
					outcomeOdds: (_.findWhere betoffer.outcomes, { popular: true }).odds

			@repository.trigger 'added:models', @repository.models


		# Unit testing of singleton
		makeTestInstance: (defaultCollection = MostPopularRepository) ->
			new MostPopularService defaultCollection

		NAME: 'MostPopularService'

	return new MostPopularService MostPopularRepository



