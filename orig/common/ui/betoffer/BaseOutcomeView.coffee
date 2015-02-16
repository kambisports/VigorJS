define (require) ->

	$ = require 'jquery'
	ComponentView = require 'common/ComponentView'

	class BaseOutcomeView extends ComponentView

		ODDS_CHANGE_TIMEOUT: 10000

		className: 'modularized__outcome modularized__js-outcome'
		tagName: 'button'
		attributes:
			'data-touch-feedback': true
			'data-name': 'outcome'
			'type': 'button'

		model: undefined
		$odds: undefined

		_oddsChangeTimeout: undefined

		initialize: ->
			super
			@listenTo @model, 'change:highlight', @render
			@listenTo @model, 'change:odds', @_onOddsChange

		render: ->
			@$odds = $ '.modularized__js-outcome-odds', @el
			@$label = $ '.modularized__js-outcome-label', @el

			@$el.attr 'data-outcome-id', @model.get('id')

			do @_setOddsAttribute
			do @_toggleHighlight
			return @

		dispose: ->
			super
			@model = undefined


		#----------------------------------------------
		# Private methods
		#----------------------------------------------
		_setOdds: ->
			oddsChangeClass = 'up'
			if (@model.previous('odds') > @model.get('odds'))
				oddsChangeClass = 'down'

			do @_removeOddsChangeClasses

			@$odds.addClass oddsChangeClass
			@$odds.html @model.get('displayOdds')

			clearTimeout @_oddsChangeTimeout
			@_oddsChangeTimeout = setTimeout @_onOddsChangeTimeout, @ODDS_CHANGE_TIMEOUT

		_setOddsAttribute: ->
			@$el.attr 'data-odds', @model.get('odds')

		# states
		_checkSuspension: ->
			if @model.get('suspended') is true
				@$el.addClass 'suspended'
			else
				@$el.removeClass 'suspended'

		_checkScratch: ->
			if @model.get('scratched') is true
				@$el.addClass 'scratched'
			else
				@$el.removeClass 'scratched'


		# Highlight
		_toggleHighlight: ->
			if @model.get('highlight')
				do @_setHighlighted
			else
				do @_removeHighlighted

		_setHighlighted: ->
			@$el.addClass 'highlighted'

		_removeHighlighted: ->
			@$el.removeClass 'highlighted'

		_removeOddsChangeClasses: ->
			@$odds.removeClass('up down')

		#----------------------------------------------
		# Callbacks
		#----------------------------------------------
		_onOddsChange: =>
			do @_setOdds
			do @_setOddsAttribute

		_onOddsChangeTimeout: =>
			do @_removeOddsChangeClasses

	return BaseOutcomeView