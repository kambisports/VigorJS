define (require) ->

	$ = require 'jquery'
	KambiApiService = require 'datacommunication/apiservices/KambiApiService'

	# TODO FIX ME
	class LoginService extends KambiApiService

		parse: (response) ->

		urlPath: ->
			''
		USER_LOGIN_RECIEVED: 'user-login-recieved'

	new LoginService()
