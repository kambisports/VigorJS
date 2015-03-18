define (require) ->

	Backbone = require 'lib/backbone'

	class UserModel extends Backbone.Model
		defaults:
			isLoggedIn: false

			# Tells if the login request has finished
			# Used for triggering initial actions in StartupCommand
			isLoginRequestFinished: false

			balance: undefined
			sessionId: ''

			# The currency that was requested for this user at client startup
			#used for making currency validation after login (see ParseLoginCommand)
			requestedCurrency: ''

			# Event hook for balance polling
			syncTimeStamp: null

	return UserModel
