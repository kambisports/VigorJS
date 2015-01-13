define (require) ->

	ComponentView = require 'common/ComponentView'
	tmpl = require 'hbs!./templates/GroupItem'

	class GroupItemView extends ComponentView

		tagName: 'li'
		className: 'event-groups__list-item'

		_viewModel: undefined

		initialize: (options) ->
			@_viewModel = options.viewModel
			super

		render: ->
			templateData = @_viewModel.group.toJSON()

			@$el.html tmpl(templateData)
			@renderDeferred.resolve @
			return @

	return GroupItemView