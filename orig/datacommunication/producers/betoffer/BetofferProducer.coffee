define (require) ->

	Producer = require 'datacommunication/producers/Producer'
	SubscriptionKeys = require 'datacommunication/SubscriptionKeys'

	# Collections needed to build/produce data
	BetoffersRepository = require 'datacommunication/repositories/betoffers/BetoffersRepository'
	OutcomesRepository = require 'datacommunication/repositories/outcomes/OutcomesRepository'

	# decorators
	betofferDecoratorBase = require 'datacommunication/producers/decorators/betoffers/betofferDecoratorBase'

	class BetofferProducer extends Producer

		constructor: ->
			super
			BetoffersRepository.on BetoffersRepository.REPOSITORY_DIFF, @_onDiffInBetofferRepository, @
			OutcomesRepository.on OutcomesRepository.REPOSITORY_DIFF, @_onDiffInOutcomeRepository, @


		dispose: ->
			BetoffersRepository.off BetoffersRepository.REPOSITORY_DIFF, @_onDiffInBetofferRepository, @
			OutcomesRepository.off OutcomesRepository.REPOSITORY_DIFF, @_onDiffInOutcomeRepository, @
			super

		subscribe: (subscriptionKey, options) ->
			betofferModel = BetoffersRepository.get options.betofferId
			@_produceData [betofferModel]

		_produceData: (betoffers = []) ->
			unless betoffers.length > 0 then return

			betoffers = _.without betoffers, undefined
			betoffers = @modelsToJSON betoffers

			for betoffer in betoffers
				betoffer = @decorate betoffer, [betofferDecoratorBase.addOutcomesToBetoffer]
				@produce SubscriptionKeys.BETOFFER, betoffer, (componentOptions) ->
					betoffer.id is componentOptions.betofferId

		_onDiffInBetofferRepository: (dataDiff) ->
			@_produceData dataDiff.consolidated

		_onDiffInOutcomeRepository: (dataDiff) ->
			if dataDiff.changed.length > 0
				betoffers = []
				for outcome in dataDiff.changed
					betoffers.push BetoffersRepository.get outcome.get('betofferId')
				@_produceData betoffers

		SUBSCRIPTION_KEYS: [SubscriptionKeys.BETOFFER]
		NAME: 'BetofferProducer'
