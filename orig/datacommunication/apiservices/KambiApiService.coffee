define (require) ->

	ApiService = require 'datacommunication/apiservices/ApiService'


	customer = ->
		window._kambi._settings.customer

	defaultQueryParams = ->
		lang: window._kambi._settings.locale
		market: window._kambi._settings.market
		client_id: 2
		channel_id: window._kambi._settings.channelId
		ncid: Date.now()


	class KambiApiService extends ApiService

		requiresAuthentication: false

		# overridable
		prefetchDataKey: undefined

		constructor: ->
			super

			# initialize with prefetched data
			if @prefetchDataKey
				modularizedPreloadedJson = window.modularizedPreloadedJson or {}
				prefetchedData = modularizedPreloadedJson[@prefetchDataKey]
				if prefetchedData
					delete window.modularizedPreloadedJson[@prefetchDataKey]
					@parse prefetchedData
					@onFetchSuccess prefetchedData

		url: (model) ->
			queryParams = @queryParams(model)
			for key, val of queryParams
				if val is undefined then delete queryParams[key]

			queryParams = _.map queryParams, (val, key) ->
				"#{key}=#{val}"

			queryParams = queryParams.join '&'
			path = @_setSessionId @urlPath(model)

			"#{@_apiBaseUrl()}#{customer()}#{path}?#{queryParams}"

		queryParams: (model) ->
			defaultQueryParams()

		urlPath: (model) ->
			throw 'KambiApiService: A service should override url and/or urlPath'

		_apiBaseUrl: ->
			if @requiresAuthentication
				apiBaseUrl = window._kambi._settings.apiAuthBaseUrl
			else
				apiBaseUrl = window._kambi._settings.apiBaseUrl
			return apiBaseUrl

		_setSessionId: (url) ->
			if @requiresAuthentication
				UsersRepository = require 'datacommunication/repositories/users/UsersRepository'
				user = UsersRepository.getUser()
				sessionId = user.get('sessionId')
				url = "#{url};jsessionid=#{sessionId}"
			return url

	KambiApiService
