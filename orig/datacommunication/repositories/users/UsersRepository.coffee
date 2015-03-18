define (require) ->

	ServiceRepository = require 'datacommunication/repositories/ServiceRepository'

	# services that receives data for this repo
	LoginService = require 'datacommunication/apiservices/LoginService'
	UserBalanceService = require 'datacommunication/apiservices/UserBalanceService'

	# the repo holds a collection of this model type
	UserModel = require 'datacommunication/repositories/users/UserModel'

	class UsersRepository extends ServiceRepository

		model: UserModel

		LOGIN: 'login'
		BALANCE: 'balance'

		services:
			'login': LoginService
			'balance': UserBalanceService

		initialize: ->
			do @moveMeToBootstrap_bootrapUser
			LoginService.on LoginService.USER_DATA_RECIEVED, @_onUserDataRecieved
			UserBalanceService.on UserBalanceService.USER_BALANCE_RECIEVED, @_onUserDataRecieved
			super

		moveMeToBootstrap_bootrapUser: ->
			@set new UserModel()

		getUser: ->
			return @models[0]

		_setUserData: (userData) ->
			user = @getUser()
			user.set userData

		_onUserDataRecieved: (userData) =>
			@_setUserData userData

		makeTestInstance: ->
			new UsersRepository()

	new UsersRepository()
