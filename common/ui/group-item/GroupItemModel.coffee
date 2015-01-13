define (require) ->

	Backbone = require 'lib/backbone'
	ViewModel = require 'common/ViewModel'
	QueryKeys = require 'datacommunication/QueryKeys'
	SubscriptionKeys = require 'datacommunication/SubscriptionKeys'

	class GroupItemModel extends ViewModel

		id: 'GroupItemModel'
		groupId: undefined
		group: undefined

		constructor: (@groupId) ->
			super
			@group = new Backbone.Model()
			do @addSubscriptions

		addSubscriptions: ->

			promise = @queryAndSubscribe QueryKeys.GROUP,
				{ groupId: @groupId},
				SubscriptionKeys.GROUPS_CHANGE,
				@onGroupChange,
				{ groupId: @groupId }

			promise.then (groups) =>
				@group.set groups

			return promise

		onGroupChange: (groups) ->
			@group.set groups

	return GroupItemModel