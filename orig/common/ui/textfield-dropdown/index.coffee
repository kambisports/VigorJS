define (require) ->

	TextfieldDropdownView = require './TextfieldDropdownView'
	TextfieldDropdownItemsCollection = require './TextfieldDropdownItemsCollection'


	class TextFieldDropdown

		_textfieldOptionCollection: undefined
		_textfieldDropdownView: undefined
		_selectedCallback: undefined

		constructor: (attributes) ->
			@_selectedCallback = attributes.selectedCallback

			@_textfieldDropdownItemsCollection = new TextfieldDropdownItemsCollection()
			@_textfieldDropdownView = new TextfieldDropdownView
				model: @_textfieldDropdownItemsCollection
				sortKey: attributes.sortKey
				sortOrder: attributes.sortOrder
				positionX: attributes.positionX
				positionY: attributes.positionY

			@addItems attributes.items if attributes.items?

			@_textfieldDropdownView.on TextfieldDropdownView.EVENT_SELECTED, @_onSelected, @

		_onSelected: ->
			(@_selectedCallback.apply @, arguments) if @_selectedCallback? #we are not extending Backbone

		addItems: (items)->
			#[{label, value<, prefix, selected>}]
			@_textfieldDropdownItemsCollection.add items

		selectItem: (value) ->
			@_textfieldDropdownItemsCollection.changeSelectedByValue value

		collapse: () ->
			@_textfieldDropdownView.collapse()

		render: () ->
			@$el = @_textfieldDropdownView.render().$el
			@

		dispose: () ->
			@_textfieldDropdownView.off TextfieldDropdownView.EVENT_SELECTED, @_onSelected, @

			@_textfieldDropdownView.dispose()
			@_textfieldDropdownView = undefined

			@_textfieldDropdownItemsCollection.reset()
			@_textfieldDropdownItemsCollection = undefined

			@_selectedCallback = undefined

		@SORT_KEY_LABEL: 'label'
		@SORT_KEY_PREFIX: 'prefix'
		@SORT_KEY_VALUE: 'value'
		@SORT_ORDER_ASC: 'ASC'
		@SORT_ORDER_DESC: 'DESC'

		@POSITION_LEFT: 'positionLeft'
		@POSITION_RIGHT: 'positionRight'
		@POSITION_SELECTED: 'positionSelected'
		@POSITION_BOTTOM: 'positionBottom'
		@POSITION_TOP: 'positionTop'