define (require) ->

	_ = require 'lib/underscore'
	Repository = require './Repository'

	ApiServices = require 'datacommunication/apiservices'

	class ServiceRepository extends Repository

		callApiService: (key, options) ->
			ApiServices.callService key, options

	return ServiceRepository