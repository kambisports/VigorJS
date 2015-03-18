define (require) ->

	$ = require 'jquery'
	ComponentView = require 'common/ComponentView'
	tmpl = require 'hbs!./templates/BreadcrumbTemplate'
	itemTmpl = require 'hbs!./templates/BreadcrumbItemTemplate'

	class BreadcrumbView extends ComponentView

		className: 'breadcrumb'
		tagName: 'nav'

		_collection: undefined
		_$list: undefined

		events:
			'click .js-breadcrumb-link': '_onLinkClick'


		initialize: ->
			super

			@_collection = @viewModel.collection
			@listenTo @_collection, 'reset', @_onCollectionReset
			@listenTo @_collection, 'add', @_onCollectionChange
			@listenTo @_collection, 'remove', @_onCollectionChange


		renderStaticContent: ->
			@$el.html tmpl {}
			@_$list = @$el.find '.js-breadcrumb-list'
			super


		renderDynamicContent: ->


		addSubscriptions: ->
			do @viewModel.addSubscriptions


		removeSubscriptions: ->
			do @viewModel.removeSubscriptions


		dispose: ->
			document.body.removeEventListener 'click', @_collapse, true
			@_$list = null
			super


		_renderItems: ->
			isActive = (index) => index is @_collection.length - 1

			for itemModel, index in @_collection.models
				$el = $ itemTmpl
					href: itemModel.get 'href'
					label: itemModel.get 'label'
					isActive: isActive index

				@_$list.append $el


		_clearItems: ->
			@_$list.empty()


		_isTopLevel: ->
			@_collection.length is 1


		_isSubLevel: ->
			@_collection.length > 1


		_updateClass: ->
			length = @_collection.length
			switch
				when @_isSubLevel()
					@$el.removeClass(@CLASS_TOP_LEVEL).addClass(@CLASS_SUB_LEVEL)
				when @_isTopLevel()
					@$el.removeClass(@CLASS_SUB_LEVEL).addClass(@CLASS_TOP_LEVEL)
				else
					@$el.removeClass "#{@CLASS_TOP_LEVEL} #{@CLASS_SUB_LEVEL}"


		_updateVisibility: ->
			if @_collection.length is 0 then do @$el.hide else do @$el.show


		_onCollectionReset: =>
			do @_clearItems
			do @_updateClass
			do @_updateVisibility


		_onCollectionChange: _.debounce ->
			do @_clearItems
			do @_renderItems
			do @_updateClass
			do @_updateVisibility


		_onLinkClick: (event) =>
			do event.stopPropagation

			if @_isTopLevel()
				do event.preventDefault
				return false

			if @$el.hasClass(@CLASS_EXPANDED)
				do @_collapse
			else
				do event.preventDefault
				do @_expand


		_expand: ->
			@$el.addClass @CLASS_EXPANDED
			document.body.addEventListener 'click', @_collapse, true


		_collapse: (e) =>
			document.body.removeEventListener 'click', @_collapse, true

			unless $(e?.target).hasClass 'js-breadcrumb-link'
				@$el.removeClass @CLASS_EXPANDED


		CLASS_TOP_LEVEL : 'breadcrumb--nav-top-level'
		CLASS_SUB_LEVEL : 'breadcrumb--nav-sub-level'
		CLASS_EXPANDED : 'breadcrumb--expanded'
		NAME : 'BreadcrumbView'

