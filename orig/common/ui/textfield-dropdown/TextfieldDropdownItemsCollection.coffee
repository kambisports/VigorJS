define (require) ->

	TextfieldDropdownItemModel = require './TextfieldDropdownItemModel'

	class TextfieldDropdownItemsCollection extends Backbone.Collection
		model: TextfieldDropdownItemModel

		add: (items = []) ->
			for item in items when not (item.label? and item.value?)
				throw 'Items added to TextfieldDropdown must have label and value specified'
			super
			@trigger 'change'

		getSelectedItem: () ->
			models = @where
				selected: true

			_.last models

		changeSelectedByValue: (value) ->
			models = @where
				value: value

			#do not deselect if there is nothing to select
			unless models.length
				return false

			@changeSelectedToItem _.last models

		changeSelectedToItem: (model) ->
			@_deselectItems @where
				selected: true

			@_selectItem model

		_selectItem: (model) ->
			if model
				model.set
					selected: true
				return true
			false

		_deselectItems: (models = []) ->
			for model in models
				model.set {selected: false}, {silent: true}

		getModels: () ->
			@models

		getSortedModels: (key, order) ->
			@models.sort (model1, model2) =>
				@_differValues (model1.get key), (model2.get key), order

		_differValues: (value1, value2, order) ->
			result = 0
			unless value1 is value2
				if value1 > value2
					result = 1
				else
					result = -1
			result *= -1 if order is 'DESC'
			result
