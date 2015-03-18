define (require) ->

	Producer = require 'datacommunication/producers/Producer'

	EventBus = require 'common/EventBus'
	EventKeys = require 'datacommunication/EventKeys'
	SubscriptionKeys = require 'datacommunication/SubscriptionKeys'

	# Collections needed to build/produce data
	EventsRepository = require 'datacommunication/repositories/events/EventsRepository'
	GroupsRepository = require 'datacommunication/repositories/groups/GroupsRepository'

	PathUtil = require 'utils/PathUtil'
	LocaleUtil = require 'utils/LocaleUtil'
	FormatUtil = require 'utils/FormatUtil'

	class BreadcrumbProducer extends Producer

		_homeItemAttr: undefined

		# the fetch subscription to the repository
		repoFetchSubscription: undefined

		constructor: ->
			super

			# Create 'Home' item attr
			# (if we want to add Home item as the first one in the breadcrumb)
			#
			@_homeItemAttr =
				id: '1'
				label: LocaleUtil.getTranslation 'home'
				href: 'home'

		dispose: ->
			super

		subscribeToRepositories: ->
			EventBus.subscribe EventKeys.PATH_CHANGE, @_pathChange

			@repoFetchSubscription =
				pollingInterval: 30 * 60 * 1000

			GroupsRepository.addSubscription GroupsRepository.ALL, @repoFetchSubscription

		unsubscribeFromRepositories: ->
			GroupsRepository.removeSubscription GroupsRepository.ALL, @repoFetchSubscription
			EventBus.unsubscribe EventKeys.PATH_CHANGE, @_pathChange


		subscribe: (subscriptionKey, options) ->


		_produceData: (pathData) ->
			data = @_buildData pathData
			dataWithHome = [@_homeItemAttr].concat data

			@produce SubscriptionKeys.BREADCRUMB_ITEMS, data
			@produce SubscriptionKeys.BREADCRUMB_ITEMS_WITH_HOME, dataWithHome


		_buildData: (pathData) ->
			fragment = pathData.fragment
			param = pathData.viewTypeParam

			data = switch
				when fragment.match(/^home/)?
					# empty breadcrumb
					[]

				when fragment.match(/^sports\/a-z/)?
					[
						id: fragment
						label: LocaleUtil.getTranslation('azSportsPage.heading')
						href: fragment
					]

				when fragment.match(/^events\/live/)?
					[
						id: fragment
						label: LocaleUtil.getTranslation('events.liveRightNow')
						href: fragment
					]

				when fragment.match(/^starts-within\//)?
					[
						id: fragment
						label: FormatUtil.minutesToStartsWithinText +param
						href: fragment
					]

				when fragment.match(/^group\//)?
					#TODO use GroupsRepository when the refactoring is done
					# and there is both prematch and live event groups stored
					# in the GroupsRepository
					#groupId = +param # id should be number
					#@_buildGroupArray groupId
					
					do @_formatObjToEventGroupsArr

				when fragment.match(/^event\//)?
					#TODO use repository when the refactoring is done
					# (we have the event data in the events repository)
					# eventId = +param # id should be number
					# event = EventsRepository.getEvent eventId
					# groupId = event.get 'groupId'
					# @_buildGroupArray groupId
					
					do @_formatObjToEventGroupsArr

				else
					[]

			data


		_pathChange: (pathData) =>
			@_produceData pathData


		#TODO use GroupsRepository when the refactoring is done
		# and there is both prematch and live event groups stored
		# in the GroupsRepository
		###
		_buildGroupArray: (groupId) ->
			groups = GroupsRepository.getAncestorArrayById groupId
			do groups.reverse

			(
				for group in groups
					id: group.get 'id'
					label: group.get 'name'
					href: "group/#{group.get 'id'}"
			)
		###

		# TODO remove it later, see comments in the _buildData
		_formatObjToEventGroupsArr: ->
			groups = _.clone PathUtil.getGroupPath()

			if groups.length
				if PathUtil.getViewType() isnt 'group'
					groups.pop()

				(
					for group in groups
						id: group.id
						label: group.name
						href: 'group/' + group.id
				)


		SUBSCRIPTION_KEYS: [
			SubscriptionKeys.BREADCRUMB_ITEMS
			SubscriptionKeys.BREADCRUMB_ITEMS_WITH_HOME
		]
