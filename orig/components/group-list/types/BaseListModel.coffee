define (require) ->

	Backbone = require 'lib/backbone'
	ViewModel = require 'common/ViewModel'
	SubscriptionKeys = require 'datacommunication/SubscriptionKeys'

	class BaseListModel extends ViewModel

		id: 'BaseListModel'

		# collection with all groups
		groups: undefined

		# model for view states
		state: undefined

		sortingMethod: undefined

		#----------------------------------------------
		# Public methods
		#----------------------------------------------

		constructor: (options) ->
			@sortingMethod = options.sortingMethod or 'highlighted-first'

			@groups = new Backbone.Collection()
			@state = new Backbone.Model
				# Expansion state of the group list.
				expanded: undefined
				# Eet to true if list should show "show more" button.
				showMore: undefined
				# Set to true when "show more" has been clicked.
				showMoreClicked: no

			super

		# Override this to return specific header for groups.
		getHeader: ->
			''

		#----------------------------------------------
		# Protected methods
		#----------------------------------------------

		# Override this to filter and sort groups.
		getGroups: ->
			@groups.models

		onGroupsChange: (groups) =>
			@groups.reset groups

		#----------------------------------------------
		# Private methods
		#----------------------------------------------
		
		#----------------------------------------------
		# Callback methods
		#----------------------------------------------

		
	return BaseListModel