define (require) ->

	Producer = require 'datacommunication/producers/Producer'
	Q = require 'lib/q'
	QueryKeys = require 'datacommunication/QueryKeys'
	SubscriptionKeys = require 'datacommunication/SubscriptionKeys'
	GroupsRepository = require 'datacommunication/repositories/groups/GroupsRepository'

	# Re-written in CS - vicweb - 10/12/2014
	# ----------------------------------------------------------------------------------------------------
	class GroupsProducer extends Producer

		# Public
		constructor: ->
			GroupsRepository.on 'change', @onChangeInRepository, @
			super

		dispose: ->
			GroupsRepository.notInterestedInUpdates @NAME
			GroupsRepository.off 'change', @onChangeInRepository, @
			super

		subscribe: (subscriptionKey, options) ->
			GroupsRepository.interestedInUpdates @NAME

		query: (queryKey, options) ->
			deferred = do Q.defer

			switch queryKey
				when QueryKeys.GROUPS
					GroupsRepository.queryGroups(options).then (data) ->
						deferred.resolve data
					return deferred.promise

				else throw 'Unknown query queryKey: #{queryKey}'
		###
		when QueryKeys.GROUP
			GroupsRepository.queryGroupById(options.groupId).then (data) ->
				deferred.resolve data
			return deferred.promise
		###

		# Handlers
		onChangeInRepository: (groupsModel) =>
			subscriptionKey = SubscriptionKeys.GROUPS_CHANGE
			groupsModelJSON = groupsModel.toJSON()
			filterFunction = (options) ->
				console.log 'options', options
				return

			@produce subscriptionKey, groupsModelJSON, filterFunction


		# Static class constants
		SUBSCRIPTION_KEYS: [SubscriptionKeys.GROUPS_CHANGE]
		QUERY_KEYS: [QueryKeys.GROUPS, QueryKeys.GROUP]

		NAME: 'GroupsProducer'

	GroupsProducer
