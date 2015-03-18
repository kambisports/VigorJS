define (require) ->

	$ = require 'jquery'
	KambiApiService = require 'datacommunication/apiservices/KambiApiService'

	CouponParser = require 'datacommunication/apiservices/parsers/CouponParser'
	OutcomeParser = require 'datacommunication/apiservices/parsers/OutcomeParser'
	CouponOutcomeParser = require 'datacommunication/apiservices/parsers/CouponOutcomeParser'
	BetofferParser = require 'datacommunication/apiservices/parsers/BetofferParser'

	class OutcomeOddsService extends KambiApiService

		requiresAuthentication: false

		onFetchSuccess: (model, result, options) =>
			requestedIds = model.get('ids')
			returnedIds = _.map result.betoffers, (betoffer) ->
				_.map betoffer.outcomes, (outcome) ->
					outcome.id

			returnedIds = _.uniq _.flatten returnedIds

			unreturnedIds = _.difference requestedIds, returnedIds

			betoffers = []
			outcomes = []

			_.each result.betoffers, (betoffer) ->

				betoffers.push BetofferParser.parse betoffer

				_.each betoffer.outcomes, (outcome) ->
					outcomes.push OutcomeParser.parse outcome

			betoffers.push @_closeBetOffersByOutcomeIds(unreturnedIds)

			@propagateResponse @OUTCOMES_RECEIVED, outcomes
			@propagateResponse @BETOFFERS_RECEIVED, betoffers

		onFetchError: (model, result, options) =>
			if result.status is 404 and result.responseJSON?
				requestedIds = model.get('ids')
				betoffers = @_closeBetOffersByOutcomeIds requestedIds
				@propagateResponse @BETOFFERS_RECEIVED, betoffers

		queryParams: (model) ->
			params = super
			model.set 'id', model.get('ids').join('&id=')
			updatedParams = _.extend params, model.toJSON()
			delete updatedParams.ids
			return updatedParams

		urlPath: (model) ->
			return '/betoffer/outcome.json'

		_closeBetOffersByOutcomeIds: (ids) ->
			betoffers = []
			for id in ids
				closedBetoffer =
					id: id
					closed: true
				betoffers.push closedBetoffer
			return betoffers

		OUTCOMES_RECEIVED: 'outcomes-recieved'
		BETOFFERS_RECEIVED: 'betoffers-received'

	new OutcomeOddsService()
