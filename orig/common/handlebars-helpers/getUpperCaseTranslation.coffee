define (require) ->

	Handlebars = require 'hbs/handlebars'
	LocaleUtil = require 'utils/LocaleUtil'
	StringUtil = require 'utils/StringUtil'

	getUpperCaseTranslation = (string) ->
		return StringUtil.toUpperCase LocaleUtil.getTranslation(string)

	Handlebars.registerHelper 'getUpperCaseTranslation', getUpperCaseTranslation
	return getUpperCaseTranslation

