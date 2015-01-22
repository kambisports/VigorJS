define (require) ->

	Backbone = require 'lib/backbone'
	ViewModel = require 'common/ViewModel'
	SubscriptionKeys = require 'datacommunication/SubscriptionKeys'

	class BaseListModel extends ViewModel

		id: 'BaseListModel'

		groups: undefined

		state: undefined

		#----------------------------------------------
		# Public methods
		#----------------------------------------------

		constructor: ->
			@groups = new Backbone.Collection()
			@state = new Backbone.Model
				expanded: undefined
				showMore: undefined

			super

		#----------------------------------------------
		# Protected methods
		#----------------------------------------------

		onGroupsChange: (groups) =>
			@groups.reset groups

		#----------------------------------------------
		# Private methods
		#----------------------------------------------
		
		#----------------------------------------------
		# Callback methods
		#----------------------------------------------

		
	return BaseListModel