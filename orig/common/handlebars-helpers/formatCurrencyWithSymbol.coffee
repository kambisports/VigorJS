define (require) ->

	Handlebars = require 'hbs/handlebars'
	ApplicationSettingsModel = require 'datacommunication/models/ApplicationSettingsModel'
	CurrencyUtil = require 'utils/CurrencyUtil'

	formatCurrencyWithSymbol = (value) ->
		return new Handlebars.SafeString CurrencyUtil.formatCurrencyWithSymbol(value, ApplicationSettingsModel.getCurrency())

	Handlebars.registerHelper 'formatCurrencyWithSymbol', formatCurrencyWithSymbol
	return formatCurrencyWithSymbol

