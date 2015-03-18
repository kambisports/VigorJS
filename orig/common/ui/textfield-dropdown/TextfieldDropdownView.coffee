define (require) ->

	_ = require 'lib/underscore'
	TextFieldDropdownItemView = require './TextFieldDropdownItemView'
	TextFieldDropdownTemplate = require 'lib/text!./TextfieldDropdown.html!strip'

	class TextfieldDropdownView extends Backbone.View ##extend ComponentView if TCMOD

		tagName: 'div'
		className: 'textfield-dropdown'
		classNameExpanded: 'textfield-dropdown--expanded'
		classNameContent: 'textfield-dropdown__list'

		_itemHeight: 40 #as this view may not have been added to DOM yet we hard code this
		_textfieldDropdownTemplate: _.template TextFieldDropdownTemplate
		_$content: undefined
		_positionOrigin: undefined
		_childViews: []
		_renderedStaticContent: false

		initialize: (attributes) ->
			@_sortKey = attributes.sortKey
			@_sortOrder = attributes.sortOrder
			@_positionY = attributes.positionY or TextfieldDropdownView.POSITION_SELECTED
			@_positionX = attributes.positionX or TextfieldDropdownView.POSITION_LEFT
			@listenTo @model, 'change', @_onCollectionChange, @

			if @_positionX is TextfieldDropdownView.POSITION_RIGHT
				@$el.css
					'right': 0

		_onItemSelected: (itemModel) ->
			if @isExpanded()
				@model.changeSelectedToItem itemModel
				@collapse()
			else
				@expand()

		isExpanded: () ->
			@$el.hasClass @classNameExpanded

		expand: () ->
			@$el.addClass @classNameExpanded
			@_repositionExpanded()

		collapse: () ->
			@$el.removeClass @classNameExpanded
			@_repositionCollapsed()

		_repositionExpanded: () ->
			@_move @_getPreferredItemIndex() #move first to see if we need to reposition it
			contentBounding = @_$content.get(0).getBoundingClientRect()
			unless @_moveByDelta contentBounding.top, moveDown = true
				@_moveByDelta (Math.max document.documentElement.clientHeight, window.innerHeight || 0) - contentBounding.bottom

		_repositionCollapsed: () ->
			@_move @model.indexOf @model.getSelectedItem()

		_moveByDelta: (delta, moveDown) ->
			direction = if moveDown then -1 else 1
			if delta < 0
				deltaSteps = Math.ceil (Math.abs delta) / @_itemHeight
				@_move @_getPreferredItemIndex() + (deltaSteps * direction)
				true
			false

		_move: (itemIndex) ->
			@_$content.css
				marginTop: (itemIndex * @_itemHeight * -1) + 'px'

		_getPreferredItemIndex: () ->
			switch @_positionY
				when TextfieldDropdownView.POSITION_BOTTOM
					preferredItemIndex = (@model.length - 1)
				when TextfieldDropdownView.POSITION_TOP
					preferredItemIndex = 0
				else
					#make sure we do not move out of viewport, like if itemModel is undefined
					preferredItemIndex = Math.max 0, @model.indexOf @model.getSelectedItem()
			preferredItemIndex

		_onCollectionChange: () ->
			if @_renderedStaticContent
				selectedItem = @model.getSelectedItem()
				@renderDynamicContent selectedItem
				if selectedItem
					@trigger TextfieldDropdownView.EVENT_SELECTED, selectedItem.get 'value'

		renderStaticContent: ->
			@$el.html @_textfieldDropdownTemplate()
			@_$content = @$el.find ".#{@classNameContent}"

			@_renderedStaticContent = true
			@renderDynamicContent @model.getSelectedItem() #data may have been added synchronous before render
			@

		renderDynamicContent: (selectedItem) ->
			if @_renderedStaticContent
				@removeDynamicContent()
				if @_sortKey
					models = @model.getSortedModels @_sortKey, @_sortOrder
				else
					models = @model.getModels()
				for model in models
					textFieldDropdownItemView = new TextFieldDropdownItemView
						model: model
					textFieldDropdownItemView.on TextFieldDropdownItemView.EVENT_SELECTED, @_onItemSelected, @
					@_childViews.push textFieldDropdownItemView
					@_$content.append textFieldDropdownItemView.render().$el
				if @isExpanded() then @_repositionExpanded() else @_repositionCollapsed()

		removeDynamicContent: ->
			for view in @_childViews
				view.off TextFieldDropdownItemView.EVENT_SELECTED, @_onItemSelected, @
				view.dispose()
			@_childViews = []

		dispose: ->
			@stopListening @model, 'change', @_onCollectionChange, @
			@removeDynamicContent()
			@$el.remove()

		@SORT_KEY_LABEL: 'label'
		@SORT_KEY_PREFIX: 'prefix'
		@SORT_KEY_VALUE: 'value'
		@SORT_ORDER_ASC: 'ASC'
		@SORT_ORDER_DESC: 'DESC'

		@EVENT_SELECTED: 'eventSelected'
		@POSITION_LEFT: 'positionLeft'
		@POSITION_RIGHT: 'positionRight'
		@POSITION_SELECTED: 'positionSelected'
		@POSITION_BOTTOM: 'positionBottom'
		@POSITION_TOP: 'positionTop'

		##inherits from ComponentView if TCMOD
		render: () ->
			@renderStaticContent()
			@