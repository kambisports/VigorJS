define (require) ->

	Handlebars = require 'hbs/handlebars'
	StringUtil = require 'utils/StringUtil'

	toUpperCase = (string) ->
		return StringUtil.toUpperCase string

	Handlebars.registerHelper 'toUpperCase', toUpperCase
	return toUpperCase

