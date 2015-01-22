define (require) ->

	Handlebars = require 'hbs/handlebars'
	LocaleUtil = require 'utils/LocaleUtil'

	getTranslation = (string) ->
		return LocaleUtil.getTranslation string

	Handlebars.registerHelper 'getTranslation', getTranslation
	return getTranslation

