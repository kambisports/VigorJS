define (require) ->

	BaseListView = require '../BaseListView'

	class RacingListView extends BaseListView

		className: ''

		concatLimit: 10

		#----------------------------------------------
		# Public methods
		#----------------------------------------------

		#----------------------------------------------
		# Overrides
		#----------------------------------------------

		renderStaticContent: ->
			super()

		addSubscriptions: ->
			super()

		removeSubscriptions: ->
			super()

		dispose: ->
			super()

		#----------------------------------------------
		# Private methods
		#----------------------------------------------

		#----------------------------------------------
		# Callback methods
		#----------------------------------------------


	return RacingListView
