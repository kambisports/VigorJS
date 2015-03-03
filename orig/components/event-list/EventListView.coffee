define (require) ->

	ComponentView = require 'common/ComponentView'
	tmpl = require 'hbs!./templates/EventList'

	class EventListView extends ComponentView

		className: ''

		# Array of all current GroupItem components
		_eventItemList: undefined

		#----------------------------------------------
		# Public methods
		#----------------------------------------------

		#----------------------------------------------
		# Overrides
		#----------------------------------------------

		initialize: (options) ->
			super


		renderStaticContent: ->
			@$el.html tmpl()

			return @

		renderDynamicContent: ->
			return

		addSubscriptions: ->
			@viewModel.addSubscriptions()

		removeSubscriptions: ->
			@viewModel.removeSubscriptions()

		dispose: ->
			super

		#----------------------------------------------
		# Private methods
		#----------------------------------------------


		#----------------------------------------------
		# Callback methods
		#----------------------------------------------


	return EventListView
