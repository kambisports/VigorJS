define (require) ->

	ApiServiceHelper = require 'datacommunication/apiservices/ApiServiceHelper'

	HelloWorldService = require 'datacommunication/apiservices/HelloWorldService'
	MostPopularService = require 'datacommunication/apiservices/MostPopularService'
	LiveEventsService = require 'datacommunication/apiservices/LiveEventsService'
	GroupsService = require 'datacommunication/apiservices/GroupsService'
	GroupsHighlightedService = require 'datacommunication/apiservices/GroupsHighlightedService'

	class ApiServices

		services: {}

		constructor: ->
			@services = {}

			@registerService MostPopularService.NAME, MostPopularService
			@registerService HelloWorldService.NAME, HelloWorldService
			@registerService LiveEventsService.NAME, LiveEventsService
			@registerService GroupsService.NAME, GroupsService
			@registerService GroupsHighlightedService.NAME, GroupsHighlightedService

		registerService: (serviceName, instance) ->
			@services[serviceName] = instance

		callService: (key, options) ->
			service = @services[key]

			unless service then throw new Error 'No registered service for call with key #{key}'
			service.run options

	return new ApiServices()