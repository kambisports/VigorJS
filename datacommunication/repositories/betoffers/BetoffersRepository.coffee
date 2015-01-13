define (require) ->

	Q = require 'lib/q'
	Repository = require 'datacommunication/repositories/Repository'
	BetofferModel = require 'datacommunication/repositories/betoffers/BetofferModel'

	class BetoffersRepository extends Repository

		model: BetofferModel

		queryBetoffer: (options) ->
			deferred = Q.defer()
			deferred.resolve @findWhere('id': options.betofferId)
			return deferred.promise

		makeTestInstance: ->
			new BetoffersRepository()

	return new BetoffersRepository()