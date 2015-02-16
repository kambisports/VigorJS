define (require) ->

	Backbone = require 'lib/backbone'

	class ApplicationSettingsModel extends Backbone.Model
		# TODO: add defaults and necessary methods
		# this model is currently being populated from AppFacade.js

		getCurrency: ->
			return @get 'currency'

		inRacingMode: ->
			return @_getBooleanSetting 'racingMode'

		_getBooleanSetting: (settingName) ->
			setting = @get  settingName

			if not setting then setting = false

			if _.isString setting
				setting = if (setting is 'true') then true else false

			setting

	return new ApplicationSettingsModel()
