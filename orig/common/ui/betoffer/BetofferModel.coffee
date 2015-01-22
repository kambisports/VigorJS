define (require) ->

	Backbone = require 'lib/backbone'
	ViewModel = require 'common/ViewModel'
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
			@subscribe SubscriptionKeys.BETOFFER_CHANGE, @_onBetofferChange, {betofferId: @betofferId}

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
		# Callbacks
		#----------------------------------------------
		_onBetofferChange: (betoffer) =>
			@outcomes.set betoffer.outcomes
			@betoffer.set betoffer

	return BetofferModel