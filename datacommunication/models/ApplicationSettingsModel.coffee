define (require) ->

	Backbone = require 'lib/backbone'

	class ApplicationSettingsModel extends Backbone.Model
		# TODO: add defaults and necessary methods
		# this model is currently being populated from AppFacade.js

		getCurrency: ->
			return @get 'currency'

		inRacingMode: ->
			return @get 'racingMode'

	return new ApplicationSettingsModel()
