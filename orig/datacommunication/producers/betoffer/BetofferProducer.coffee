define (require) ->

	Producer = require 'datacommunication/producers/Producer'

	SubscriptionKeys = require 'datacommunication/SubscriptionKeys'

	# Collections needed to build/produce data
	BetoffersRepository = require 'datacommunication/repositories/betoffers/BetoffersRepository'
	OutcomesRepository = require 'datacommunication/repositories/outcomes/OutcomesRepository'

	class BetofferProducer extends Producer

		_debouncedOnOutcomeRepositoryAdd: undefined
		_debouncedOnOutcomeRepositoryChange: undefined
		_debouncedOnOutcomeRepositoryRemove: undefined

		constructor: ->
			@_debouncedOnOutcomeRepositoryAdd = _.debounce @_onChangesInOutcomeRepository, 0
			@_debouncedOnOutcomeRepositoryChange = _.debounce @_onChangesInOutcomeRepository, 0
			@_debouncedOnOutcomeRepositoryRemove = _.debounce @_onChangesInOutcomeRepository, 0

			OutcomesRepository.on 'add', @_debouncedOnOutcomeRepositoryAdd, @
			OutcomesRepository.on 'change', @_debouncedOnOutcomeRepositoryChange, @
			OutcomesRepository.on 'remove', @_debouncedOnOutcomeRepositoryRemove, @

			BetoffersRepository.on 'change', @_onChangesInBetofferRepository, @
			super

		dispose: ->
			BetoffersRepository.off 'change', @_onChangesInBetofferRepository, @

			OutcomesRepository.off 'add', @_debouncedOnOutcomeRepositoryAdd, @
			OutcomesRepository.off 'change', @_debouncedOnOutcomeRepositoryChange, @
			OutcomesRepository.off 'remove', @_debouncedOnOutcomeRepositoryRemove, @

			_debouncedOnOutcomeRepositoryAdd: undefined
			_debouncedOnOutcomeRepositoryChange: undefined
			_debouncedOnOutcomeRepositoryRemove: undefined
			super

		addRespositoryListeners: () ->
			BetoffersRepository.on 'change', @onChangesInBetofferRepository, @

			OutcomesRepository.on 'add', @onOutcomeRepositoryAdd, @
			OutcomesRepository.on 'change', @onOutcomeRepositoryChange, @
			OutcomesRepository.on 'remove', @onOutcomeRepositoryRemove, @

		removeRespositoryListeners: () ->
			BetoffersRepository.off 'change', @onChangesInBetofferRepository, @

			OutcomesRepository.off 'add', @onOutcomeRepositoryAdd, @
			OutcomesRepository.off 'change', @onOutcomeRepositoryChange, @
			OutcomesRepository.off 'remove', @onOutcomeRepositoryRemove, @

		subscribe: (subscriptionKey, options) ->
			switch subscriptionKey
				when SubscriptionKeys.BETOFFER_CHANGE
					betofferModel = BetoffersRepository.queryBetoffer(options)
					if betofferModel then @_produceDataFromBetoffer betofferModel
				else
					throw new Error("Unknown subscription subscriptionKey: #{subscriptionKey}")

		_produceDataFromBetoffer: (betofferModel) ->
			betofferData = @_buildData betofferModel
			@produce SubscriptionKeys.BETOFFER_CHANGE, betofferData, (componentOptions) ->
				betofferData.id is componentOptions.betofferId

		# Any change, add, remove of outcome in outcome repository should generate the same bet offer changed subscription
		_produceDataFromOutcome: (outcomeModel) ->
			boId = outcomeModel.get 'betofferId'
			betofferModel = BetoffersRepository.queryBetoffer { betofferId: boId }

			if betofferModel then @_produceDataFromBetoffer betofferModel

		# Handlers
		_onChangesInBetofferRepository: (betofferModel) ->
			@_produceDataFromBetoffer betofferModel

		_onChangesInOutcomeRepository: (outcomeModel) ->
			@_produceDataFromOutcome outcomeModel

		# Builders
		# Dummy formatting, outcomesdata shuld come straight from the outcomes collection
		_buildData: (betofferModel) ->
			betofferData = betofferModel.toJSON()
			betofferData.outcomes = @_buildOutcomesData betofferData.id
			return betofferData

		_buildOutcomesData: (betofferId) ->
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

		NAME: 'BetofferProducer'
