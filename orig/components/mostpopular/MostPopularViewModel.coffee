define (require) ->

	Backbone = require 'lib/backbone'
	ViewModel = require 'common/ViewModel'
	SubscriptionKeys = require 'datacommunication/SubscriptionKeys'

	class MostPopularViewModel extends ViewModel

		id: 'MostPopularViewModel'
		events: undefined
		selectedOutcomes: undefined
		defaultStakes: undefined
		combinedOdds: 0

		constructor: ->
			@selectedOutcomes = new Backbone.Collection()
			@defaultStakes = new Backbone.Model()
			@selectedOutcomes.on 'reset', @calculateCombinedOdds
			super

		addSubscriptions: ->
			@subscribe SubscriptionKeys.NEW_MOST_POPULAR_EVENTS, @_onNewEvents, {}

		calculateCombinedOdds: =>
			combinedOdds = if @selectedOutcomes.length then 1 else 0
			@selectedOutcomes.each (outcome) ->
				combinedOdds *= outcome.get('odds') / 1000
			@combinedOdds = combinedOdds

		getPotentialPayout: (stake) ->
			return @combinedOdds * stake


		#----------------------------------------------
		# Private methods
		#----------------------------------------------
		_storeData: (data) =>
			@events = data.events
			@defaultStakes.set 'stakes', data.defaultStakes
			@selectedOutcomes.reset data.selectedOutcomes

		#----------------------------------------------
		# Callbacks
		#----------------------------------------------
		_onNewEvents: (data) =>
			@_storeData data

	return MostPopularViewModel