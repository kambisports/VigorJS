define (require) ->

	Backbone = require 'lib/backbone'

	class BreadcrumbItemModel extends Backbone.Model

		defaults:
			# String
			id: undefined

			# String
			label: undefined

			# String
			href: undefined