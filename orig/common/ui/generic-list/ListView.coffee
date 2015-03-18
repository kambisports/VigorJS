define (require) ->
	
	$ = require 'jquery'
	_ = require 'lib/underscore'
	Backbone = require 'lib/backbone'
	ComponentView = require 'common/ComponentView'
	
	class ListView extends Backbone.View

		_isRendered: false
		_sortHash: undefined
		
		initialize: (options) ->

			@_itemViews = @collection.map (model) =>
				new @ItemView
					model: model

			@_updateSortHash()

			@listenTo @collection, 'add', @_onItemAdd
			@listenTo @collection, 'remove', @_onItemRemove
			@listenTo @collection, 'sort', @_onSort
			@listenTo @collection, 'reset', @_onReset


		dispose: ->

			_.invoke @_itemViews, 'dispose'

			@stopListening()

			@_itemViews = undefined
			@$_detachedEl = undefined


		render: ->
			fragment = window.document.createDocumentFragment()

			_.each @_itemViews, (view) ->
				fragment.appendChild view.render().el

			@$el.append fragment

			@_isRendered = true

			@

		detach: ->
			@$_detachedEl = @$el.detach()

		attach: ->
			if @_isRendered
				if @$_detachedEl?
					fragment = document.createDocumentFragment()
					@$_detachedEl.children().appendTo fragment
					@$el.append fragment

					@$_detachedEl = undefined
				else
					# fail silently if we're rendered but not detached
					undefined
			else
				@render()


		_onItemAdd: (model, collection, options) ->
			models = collection.models

			# create a view to insert
			view = new @ItemView
				model: model
			
			# insert the view into the list in the correct position
			@_itemViews[models.indexOf model] = view

			# insert the view into the DOM in the correct position
			# do this instead of rendering all dynamic content to avoid unnecessary DOM work
			$itemViewEl = view.render().$el
			index = models.indexOf model
			$previousEl = undefined

			# we have the rendered el and the required index; now insert
			i = index - 1
			while i >= 0
				if @_itemViews[i]?.$el
					$previousEl = @_itemViews[i].$el
					break
				i -= 1

			if $previousEl
				$itemViewEl.insertAfter $previousEl

			else
				@$el.prepend $itemViewEl
			
			@_updateSortHash()


		_onItemRemove: (model, collection, options) ->
			@_itemViews = @_itemViews.filter (view) ->
				if view.model.id is model.id
					do view.el.remove
					do view.dispose
					false
				else
					true

			@_updateSortHash()


		_onSort: (collection) ->

			if @_didChangeSortOrder()

				models = @collection.models

				# each item in sortIndices is the destination index for the value at that index
				sortIndices = _.map @_itemViews, (view) ->
					models.indexOf view.model

				# invert the array so each item is the index of the item that should be put at that index
				sortIndices = _.invert sortIndices

				@_itemViews = _.map sortIndices, (index) =>
					@_itemViews[index]

				fragment = window.document.createDocumentFragment()
				_.each @_itemViews, (view) ->
					view.$el.detach()
					fragment.appendChild view.el

				@$el.append fragment


		_onReset: (collection) ->
			@$el.empty()

			_.invoke @_itemViews, 'dispose'

			@$_detachedEl = undefined

			@_itemViews = @collection.map (model) =>
				new @ItemView
					model: model

			@renderStaticContent()

			@_updateSortHash()


		_updateSortHash: ->
			@_sortHash = @_getSortHash()


		_didChangeSortOrder: ->
			sortHash = @_getSortHash()
			if sortHash isnt @_sortHash
				@_sortHash = sortHash
				true
			else
				false


		_getSortHash: ->
			@collection.reduce (memo, model) ->
				"#{ memo };#{model.id}"
			, ""

	ListView
