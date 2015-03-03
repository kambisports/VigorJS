define (require) ->

	$ = require 'jquery'
	KambiApiService = require 'datacommunication/apiservices/KambiApiService'
	CustomerSettingsModel = require 'datacommunication/models/CustomerSettingsModel'

	class UserBalanceService extends KambiApiService

		fetch: ->
			CustomerSettingsModel.getBalance(@_onSuccess, @_onError)

		parse: (balance) =>
			# Set the data in our repositories so that components later on can request (query) that data
			balanceObj =
				balance: balance
				syncTimeStamp: Date.now()

			@propagateResponse @USER_BALANCE_RECIEVED, balanceObj

		_onSuccess: (data) =>
			@parse data

		_onError: (error) ->
			console.log 'Balance request error: ', error
			@propagateResponse @USER_BALANCE_RECIEVED, undefined

		USER_BALANCE_RECIEVED: 'user-balance-recieved'

	new UserBalanceService()
