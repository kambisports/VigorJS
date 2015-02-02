define (require) ->

	Repository = require 'datacommunication/repositories/Repository'
	BetofferModel = require 'datacommunication/repositories/betoffers/BetofferModel'

	class BetoffersRepository extends Repository

		model: BetofferModel

		queryBetoffer: (options) ->
			return @findWhere('id': options.betofferId)

		makeTestInstance: ->
			new BetoffersRepository()

	return new BetoffersRepository()