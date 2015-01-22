define ->

	Backbone = require 'lib/backbone'

	class ApiServiceHelper

		serviceToUrl:
			'MostPopularService' : '/betoffer/mostpopular/3way.json'
			'GroupsService' : '/group.json'
			'GroupsHighlightedService': '/group/highlight.json'

		# Base sync
		sync: (method, model, options) =>
			prefetchedDataKey = @_getPrefetchDataKey(options)
			prefetchedData = @_getPrefetchedData(prefetchedDataKey)

			# if we have prefetched data, call options.success with that data
			if prefetchedData
				@_runPrefetchedDataSuccessHandler(prefetchedData, options)
			else
				# else continue as normal with backbone sync
				return Backbone.sync(method, model, options)

		getUrl: (serviceName) ->
			switch serviceName
				when 'LiveService', 'GroupsHighlightedService', 'GroupsService', 'MostPopularService'
					return @_getOfferingBaseUrl() + @_getCustomer() + @_getServiceUrl(serviceName) + @_getParams()
				when 'HelloWorldService'
					return './js/datacommunication/repositories/helloworld/helloWorld.json'
				else
					throw 'ApiServiceHelper: A service should have a mapped url to it'

		_getOfferingBaseUrl: ->
			return window._kambi._settings.apiBaseUrl

		_getServiceUrl: (serviceName) ->
			return @serviceToUrl[serviceName]

		_getCustomer: ->
			return window._kambi._settings.customer

		_getParams: ->
			return """?lang=#{window._kambi._settings.locale}\
					&market=#{window._kambi._settings.market}\
					&client_id=2\
					&channel_id=#{window._kambi._settings.channelId}\
					&ncid=#{Date.now()}"""

		_runPrefetchedDataSuccessHandler: (prefetchedData, options) ->
			fakeXhr =
				status: 200
				payload: options.payload

			# We must set xhr on options (see: https://github.com/jashkenas/backbone/issues/1939)
			options.xhr = fakeXhr
			options.success prefetchedData, 200, fakeXhr

		_getPrefetchDataKey: (options) ->
			key = options?.prefetchDataKey
			if key then delete options.prefetchDataKey
			return key

		_getPrefetchedData: (prefetchDataKey) ->
			window.modularizedPreloadedJson = window.modularizedPreloadedJson || {}
			prefetchedData = window.modularizedPreloadedJson[prefetchDataKey]
			if prefetchedData then delete window.modularizedPreloadedJson[prefetchDataKey]

			return prefetchedData

	return new ApiServiceHelper()