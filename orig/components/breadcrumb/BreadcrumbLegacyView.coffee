define (require) ->

	$ = require 'jquery'
	BreadcrumbView = require './BreadcrumbView'
	tmpl = require 'hbs!./templates/BreadcrumbLegacyTemplate'
	itemTmpl = require 'hbs!./templates/BreadcrumbLegacyItemTemplate'

	class BreadcrumbLegacyView extends BreadcrumbView

		className: 'breadcrumb breadcrumb--legacy'

		# Override #
		renderStaticContent: ->
			@$el.html tmpl {}
			@_$list = @$el.find '.js-breadcrumb-list'

		
		# Override #
		_renderItems: ->
			isLast = (index) => index is @_collection.length - 1

			for itemModel, index in @_collection.models
				$el = $ itemTmpl
					href: itemModel.get 'href'
					label: itemModel.get 'label'
					isLast: isLast index
				
				@_$list.append $el


		# Override #
		_isTopLevel: ->
			@_collection.length is 2


		# Override #
		_isSubLevel: ->
			@_collection.length > 2


		# Override #
		_updateClass: ->
			# do nothing


		# Override #
		_onLinkClick: ->
			# do nothing

		
		renderDynamicContent: -> super
		addSubscriptions: -> super
		removeSubscriptions: -> super
		dispose: -> super

		