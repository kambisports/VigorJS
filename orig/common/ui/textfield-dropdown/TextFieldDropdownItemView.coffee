define (require) ->

	_ = require 'lib/underscore'
	TextFieldDropdownTemplateItem = require 'lib/text!./TextfieldDropdownItem.html!strip'

	class TextFieldDropdownItemView extends Backbone.View

		_textfieldDropdownTemplateItem: _.template TextFieldDropdownTemplateItem

		tagName: 'li'
		className: 'textfield-dropdown__item'
		classNameSelected: 'textfield-dropdown__item--selected'

		events:
			'click': '_onClick'

		_onClick: ->
			@trigger TextFieldDropdownItemView.EVENT_SELECTED, @model

		render: ->
			@$el.html @_textfieldDropdownTemplateItem
				prefix: @model.get 'prefix'
				label: @model.get 'label'

			@$el.attr
				'data-value': @model.get 'value'
				'data-touch-feedback': 'true'
			@$el.toggleClass @classNameSelected, @model.get 'selected'
			@

		dispose: ->
			@$el.remove()

		@EVENT_SELECTED: 'eventSelected'