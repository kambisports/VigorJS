define () ->

	class TextfieldDropdownItemModel extends Backbone.Model

		defaults:
			label: undefined
			prefix: undefined
			value: undefined
			selected: false