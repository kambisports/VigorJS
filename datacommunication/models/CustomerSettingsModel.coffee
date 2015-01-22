define (require) ->

	Backbone = require 'lib/backbone'

	class CustomerSettingsModel extends Backbone.Model
		# TODO: add defaults and necessary methods
		# this model is currently being populated from AppFacade.js

	return new CustomerSettingsModel()