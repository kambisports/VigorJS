define (require) ->

	_ = require 'lib/underscore'
	Backbone = require 'lib/backbone'

	class ServiceRepository extends Backbone.Collection

		producersInterestedInUpdates: undefined

		initialize: ->
			@producersInterestedInUpdates = []
			super

		isEmpty: ->
			return @models.length <= 0

		interestedInUpdates: (name) ->
			producerAlreadyInterested = _.indexOf(@producersInterestedInUpdates, name) > 0
			unless producerAlreadyInterested then @producersInterestedInUpdates.push name

			if @producersInterestedInUpdates.length > 0 then @trigger ServiceRepository::START_POLLING

		notInterestedInUpdates: (name) ->
			interestedProducerIndex = _.indexOf(@producersInterestedInUpdates, name) > 0
			if interestedProducerIndex then @producersInterestedInUpdates.splice interestedProducerIndex, 1

			if @producersInterestedInUpdates.length is 0 then @trigger ServiceRepository::STOP_POLLING

		POLL_ONCE: 'poll_once'
		START_POLLING: 'start_polling'
		STOP_POLLING: 'stop_polling'

	return ServiceRepository