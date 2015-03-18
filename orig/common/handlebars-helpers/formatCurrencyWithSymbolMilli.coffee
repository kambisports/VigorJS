define (require) ->

	Handlebars = require 'hbs/handlebars'

	formatCurrencyWithSymbol = require 'common/handlebars-helpers/formatCurrencyWithSymbol'

	formatCurrencyWithSymbolMilli = (value) ->
		formatCurrencyWithSymbol (value / 1000)


	Handlebars.registerHelper 'formatCurrencyWithSymbolMilli', formatCurrencyWithSymbolMilli
	formatCurrencyWithSymbolMilli