define (require) ->

	Handlebars = require 'hbs/handlebars'
	StringUtil = require 'utils/StringUtil'

	toUpperCase = (string) ->
		return new Handlebars.SafeString StringUtil.toUpperCase(string)

	Handlebars.registerHelper 'toUpperCase', toUpperCase
	return toUpperCase

