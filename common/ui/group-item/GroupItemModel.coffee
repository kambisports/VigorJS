define (require) ->

	Backbone = require 'lib/backbone'
	ViewModel = require 'common/ViewModel'
	QueryKeys = require 'datacommunication/QueryKeys'
	SubscriptionKeys = require 'datacommunication/SubscriptionKeys'

	class GroupItemModel extends ViewModel

		id: 'GroupItemModel'
		group: undefined

		constructor: (group) ->
			super
			@group = new Backbone.Model()
			@group.set group.toJSON()

	return GroupItemModel