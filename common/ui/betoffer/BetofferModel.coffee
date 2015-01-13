define (require) ->

	Backbone = require 'lib/backbone'
	ViewModel = require 'common/ViewModel'
	QueryKeys = require 'datacommunication/QueryKeys'
	SubscriptionKeys = require 'datacommunication/SubscriptionKeys'

	class BetofferModel extends ViewModel

		id: 'BetofferModel'
		betofferId: undefined
		betoffer: undefined
		outcomes: undefined

		#----------------------------------------------
		# Public methods
		#----------------------------------------------
		constructor: (@betofferId) ->
			super
			@betoffer = new Backbone.Model()
			@outcomes = new Backbone.Collection()


		addSubscriptions: ->
			promise = @queryAndSubscribe QueryKeys.BETOFFER,
				{betofferId: @betofferId},
				SubscriptionKeys.BETOFFER_CHANGE,
				@_onBetofferChange,
				{betofferId: @betofferId}

			promise.then (betoffer) =>
				@betoffer.set betoffer
				@outcomes.reset betoffer.outcomes

			return promise


		getSelectedOutcomes: ->
			highlighted = _.filter @outcomes.toJSON(), (outcome) ->
				outcome.highlight

			outcomes = _.map highlighted, (outcome) ->
				return {
					outcomeId: outcome.id
					odds: outcome.odds
				}
			return outcomes

		#----------------------------------------------
		# Private methods
		#----------------------------------------------

		#----------------------------------------------
		# Callbacks
		#----------------------------------------------
		_onBetofferChange: (betoffer) =>
			@betoffer.set betoffer
			@outcomes.set betoffer.outcomes

	return BetofferModel