define (require) ->

	Q = require 'lib/q'
	Producer = require 'datacommunication/producers/Producer'

	QueryKeys = require 'datacommunication/QueryKeys'
	SubscriptionKeys = require 'datacommunication/SubscriptionKeys'

	# Collections needed to build/produce data
	BetoffersRepository = require 'datacommunication/repositories/betoffers/BetoffersRepository'
	OutcomesRepository = require 'datacommunication/repositories/outcomes/OutcomesRepository'

	class BetofferProducer extends Producer

		constructor: ->
			do @addRespositoryListeners
			super

		dispose: ->
			do @removeRespositoryListeners
			super

		addRespositoryListeners: () ->
			BetoffersRepository.on 'change', @onBetOfferRepositoryChange, @

			OutcomesRepository.on 'add', @onOutcomeRepositoryAdd, @
			OutcomesRepository.on 'change', @onOutcomeRepositoryChange, @
			OutcomesRepository.on 'remove', @onOutcomeRepositoryRemove, @

		removeRespositoryListeners: () ->
			BetoffersRepository.off 'change', @onBetOfferRepositoryChange, @

			OutcomesRepository.off 'add', @onOutcomeRepositoryAdd, @
			OutcomesRepository.off 'change', @onOutcomeRepositoryChange, @
			OutcomesRepository.off 'remove', @onOutcomeRepositoryRemove, @

		query: (queryKey, options) ->
			deferred = Q.defer()
			# console.log 'BetofferProducer.query', queryKey, options
			switch queryKey
				when QueryKeys.BETOFFER
					BetoffersRepository.queryBetoffer(options).then (data) =>
						deferred.resolve @buildData data
					return deferred.promise
				else
					throw new Error("Unknown query queryKey: #{queryKey}")

		# Handlers
		onBetOfferRepositoryChange: (betofferModel) ->
			window.console.log 'onBetOfferRepositoryChange', betofferModel

		onOutcomeRepositoryChange: (outcomeModel) ->
			@generateBetofferChangeFromOutcome outcomeModel

		onOutcomeRepositoryAdd: (outcomeModel) ->
			@generateBetofferChangeFromOutcome outcomeModel

		onOutcomeRepositoryRemove: (outcomeModel) ->
			@generateBetofferChangeFromOutcome outcomeModel

		# Any change, add, remove of outcome in outcome repository should generate the same bet offer changed subscription
		generateBetofferChangeFromOutcome: (outcomeModel) ->
			boId = outcomeModel.get 'betofferId'
			BetoffersRepository.queryBetoffer({ betofferId: boId }).then (betofferModel) =>
				betofferData = @buildData betofferModel
				@produce SubscriptionKeys.BETOFFER_CHANGE, betofferData, (componentOptions) ->
					betofferData.id is componentOptions.betofferId

		# Builders
		# Dummy formatting, outcomesdata shuld come straight from the outcomes collection
		buildData: (betofferModel) ->
			betofferData = betofferModel.toJSON()
			betofferData.outcomes = @buildOutcomesData betofferData.id
			return betofferData

		buildOutcomesData: (betofferId) ->
			outcomeObjs = []
			outcomeModels = OutcomesRepository.findOutcomesByBetofferId betofferId

			for outcomeModel in outcomeModels
				outcome = outcomeModel.toJSON()
				outcome.displayOdds = (outcome.odds / 1000).toFixed(2)
				if outcome.popular
					outcome.highlight = true
				outcomeObjs.push outcome

			return outcomeObjs

		SUBSCRIPTION_KEYS: [SubscriptionKeys.BETOFFER_CHANGE]
		QUERY_KEYS: [QueryKeys.BETOFFER]

		NAME: 'BetofferProducer'
