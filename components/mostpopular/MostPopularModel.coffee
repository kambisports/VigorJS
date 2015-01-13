define (require) ->

	Backbone = require 'lib/backbone'
	ViewModel = require 'common/ViewModel'
	QueryKeys = require 'datacommunication/QueryKeys'
	SubscriptionKeys = require 'datacommunication/SubscriptionKeys'

	class MostPopularModel extends ViewModel

		id: 'MostPopularModel'
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
			promise = @queryAndSubscribe QueryKeys.MOST_POPULAR_EVENTS,
				{},
				SubscriptionKeys.NEW_MOST_POPULAR_EVENTS,
				@_onNewEvents,
				{}

			promise.then @_storeData
			return promise

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

	return MostPopularModel