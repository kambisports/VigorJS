define (require) ->

	_ = require 'lib/underscore'
	PackageBase = require 'common/PackageBase'
	BreadcrumbView = require './BreadcrumbView'
	BreadcrumbLegacyView = require './BreadcrumbLegacyView'
	BreadcrumbViewModel = require './BreadcrumbViewModel'

	class Breadcrumb extends PackageBase

		# private properties
		$el: undefined
		_viewModel: undefined
		_breadcrumbView: undefined

		#----------------------------------------------
		# Public methods
		#----------------------------------------------
		constructor: (options) ->
			super
			{@enableNewFrameworkLayout} = options

			@_viewModel = new BreadcrumbViewModel
				enableNewFrameworkLayout: @enableNewFrameworkLayout
			
			viewClass = if @enableNewFrameworkLayout then BreadcrumbView else BreadcrumbLegacyView

			@_breadcrumbView = new viewClass
				viewModel: @_viewModel

		render: ->
			@$el = @_breadcrumbView.render().$el
			_.defer =>
				do @renderDeferred.resolve
			return @

		dispose: =>
			do @_breadcrumbView?.dispose
			@_breadcrumbView = undefined
			@_viewModel?.dispose false
			@_viewModel = undefined


		NAME: 'Breadcrumb'