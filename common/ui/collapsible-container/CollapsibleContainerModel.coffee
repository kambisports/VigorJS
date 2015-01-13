define (require) ->

	ViewModel = require 'common/ViewModel'

	class CollapsibleContainerModel extends ViewModel

		id: 'CollapsibleContainerModel'

		title: undefined

		constructor: (options) ->
			@title = options.title
			super

	return CollapsibleContainerModel