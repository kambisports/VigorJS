define (require) ->

	_ = require 'lib/underscore'
	Backbone = require 'lib/backbone'
	Poller = require 'lib/backbone.poller'

	ApiServiceHelper = require 'datacommunication/apiservices/ApiServiceHelper'

	###
		Base class for services interacting with the API (polling)
	###

	class ApiService

		service: undefined
		poller: undefined
		pollerOptions: undefined
		shouldStop: false

		# Override this for prefetched resources
		prefetchDataKey: 'OverrideMe'


		# Repository to listen for active listeners on, Default poll interval is 10 seconds
		constructor: (pollInterval = 10000) ->
			@service = new Backbone.Model()
			@service.url = ApiServiceHelper.getUrl @NAME
			@service.sync = ApiServiceHelper.sync
			@service.parse = @parse

			@pollerOptions = {
				delay: pollInterval
				delayed: false
				continueOnError: true
				autostart: false
				prefetchDataKey: @prefetchDataKey
			}

			@_createPoller @pollerOptions

		dispose: () ->
			do @_unbindPollerListeners

			@service = undefined
			@poller = undefined

		# This should be run from the class implementing this base
		parse: (response) =>
			@_validateResponse response isnt true
			if @shouldStop
				do @poller.stop

		startPolling: =>
			do @poller?.start

		run: ->
			throw 'ApiService->run must be overriden.'

		stopPolling: =>
			if @poller.active()
				@shouldStop = true
			else
				do @poller.stop

		propagateResponse: (key, responseData) ->
			@trigger key, responseData

		_createPoller: (options) ->
			@poller = Poller.get @service, options

			do @_unbindPollerListeners
			do @_bindPollerListeners

		_bindPollerListeners: () ->

			###
			@poller.on 'success',  ->
				window.console.log 'Api service poller success'

			@poller.on 'complete', ->
				window.console.log 'Api service poller complete'
			###

			@poller.on 'error', (e) ->
				window.console.log 'Api service poller error', arguments, @

		_unbindPollerListeners: () ->
			do @poller?.off

		# FIXME
		# Check xhr status in some generic way here?
		# Or use the backbone validate method in the models?
		_validateResponse: (response) ->
			removeThisLineOfCode = response
			return true


		_.extend @prototype, Backbone.Events

	return ApiService


