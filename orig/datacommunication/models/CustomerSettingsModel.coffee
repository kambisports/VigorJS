define (require) ->

	Backbone = require 'lib/backbone'
	_ = require 'lib/underscore'

	class CustomerSettingsModel extends Backbone.Model
		# TODO: add defaults and necessary methods
		# this model is currently being populated from AppFacade.js

		getBalance: (successCallback, failureCallback) ->
			getBalance = @get 'getBalance'
			if _.isFunction(getBalance)
				getBalance(successCallback, failureCallback, $);

	return new CustomerSettingsModel()