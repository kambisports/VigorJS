define (require) ->

	Backbone = require 'lib/backbone'
	Poller = require 'lib/backbone.poller'

	ApiServiceHelper = require 'datacommunication/apiservices/ApiServiceHelper'
	ServiceRepository = require 'datacommunication/repositories/ServiceRepository'

	###
		Base class for services interacting with the API (polling)
		Each service is bound to a repository and whenever that repository has a listener
		for data, the service will start polling. If the repository has no active listeners the
		service will stop polling for data.
	###

	class ApiService

		service: undefined
		repository: undefined
		poller: undefined
		pollerOptions: undefined
		shouldStop: false

		# Override this for prefetched resources
		prefetchDataKey: 'OverrideMe'


		# Repository to listen for active listeners on, Default poll interval is 10 seconds
		constructor: (@repository, pollInterval = 10000) ->
			@service = new Backbone.Model()
			@service.url = ApiServiceHelper.getUrl @NAME
			@service.sync = ApiServiceHelper.sync
			@service.parse = @parse

			if @repository then do @bindRepositoryListeners

			@pollerOptions = {
				delay: pollInterval
				delayed: false
				continueOnError: true
				autostart: false
				prefetchDataKey: @prefetchDataKey
			}

			@_createPoller @pollerOptions

		dispose: () ->
			if @repository then	do @unbindRepositoryListeners
			do @_unbindPollerListeners

			@service = undefined
			@poller = undefined

		# This should be run from the class implementing this base
		parse: (response) =>
			@_validateResponse response isnt true
			if @shouldStop
				do @poller.stop

		bindRepositoryListeners: () ->
			@service.listenTo @repository, ServiceRepository::START_POLLING, @_startPolling
			@service.listenTo @repository, ServiceRepository::STOP_POLLING, @_stopPolling
			@service.listenTo @repository, ServiceRepository::POLL_ONCE, @pollOnce

		unbindRepositoryListeners: () ->
			@service.stopListening @repository, ServiceRepository::START_POLLING, @_startPolling
			@service.stopListening @repository, ServiceRepository::STOP_POLLING, @_stopPolling
			@service.stopListening @repository, ServiceRepository::POLL_ONCE, @pollOnce

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

		_startPolling: =>
			do @poller?.start

		_stopPolling: =>
			if @poller.active()
				@shouldStop = true
			else
				do @poller.stop

		###
		pollOnce: =>

			# if the poller is active (we have a running subscription) we should stop poller and fire
			# a request without delay and then restart polling
			if @poller.active()
				shouldRestart = true

			# if the poller isn't active we can just proceed by fire one request and then stop poller

			# by creating a new poller it will stop any exisiting poller for this service
			@_createPoller {
				delay: 0
				delayed: true
				continueOnError: true
				autostart: false
				prefetchDataKey: @prefetchDataKey
			}

			pollOnceHandler = () =>
				do @_unbindPollerListeners

				# reset poller options if a subscription comes along in a later stage
				@_createPoller @pollerOptions

				if shouldRestart
					do @_startPolling

			@poller.on 'success', pollOnceHandler
			@poller.on 'error', pollOnceHandler

			# trigger poll once
			do @poller.start
		###

		# Check xhr status in some generic way here?
		# or use the backbone validate methdo in the models?
		_validateResponse: (response) ->
			removeThisLineOfCode = response
			return true

	return ApiService



