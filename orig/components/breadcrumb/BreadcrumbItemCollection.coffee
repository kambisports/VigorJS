define (require) ->

	Backbone = require 'lib/backbone'
	BreadcrumbItemModel = require './BreadcrumbItemModel'

	class BreadcrumbItemCollection extends Backbone.Collection

		model: BreadcrumbItemModel

		NAME: 'BreadcrumbItemCollection'