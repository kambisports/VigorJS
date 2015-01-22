define (require) ->

	Q = require 'lib/q'
	ServiceRepository = require 'datacommunication/repositories/ServiceRepository'

	MostPopularModel = require 'datacommunication/repositories/mostpopular/MostPopularModel'

	class MostPopularRepository extends ServiceRepository

		model: MostPopularModel

		queryBetoffers: ->
			unless @isEmpty() then return @models
			return []

		makeTestInstance: () ->
			new MostPopularRepository()

	return new MostPopularRepository()