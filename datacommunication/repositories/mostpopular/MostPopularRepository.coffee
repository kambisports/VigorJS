define (require) ->

	Q = require 'lib/q'
	ServiceRepository = require 'datacommunication/repositories/ServiceRepository'

	MostPopularModel = require 'datacommunication/repositories/mostpopular/MostPopularModel'

	class MostPopularRepository extends ServiceRepository

		model: MostPopularModel

		queryBetoffers: ->
			deferred = Q.defer()

			unless @isEmpty() then deferred.resolve @models

			@listenToOnce @, 'added:models', ->
				deferred.resolve @models

			@trigger ServiceRepository::POLL_ONCE

			return deferred.promise

		makeTestInstance: () ->
			new MostPopularRepository()

	return new MostPopularRepository()