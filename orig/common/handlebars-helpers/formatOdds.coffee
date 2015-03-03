define (require) ->

	Handlebars = require 'hbs/handlebars'
	OddsUtil = require 'utils/OddsUtil'

	formatOdds = (value) ->
		new Handlebars.SafeString OddsUtil.getOdds value

	Handlebars.registerHelper 'formatOdds', formatOdds

	formatOdds

