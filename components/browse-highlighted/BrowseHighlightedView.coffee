define (require) ->

	ComponentView = require 'common/ComponentView'
	browseHighlightedTemplate = require 'hbs!./templates/BrowseHighlighted'

	class BrowseHighlightedView extends ComponentView

		tagName: 'section'
		className: 'navigation-menu__section navigation-menu__section--popular widget'

		_viewModel: undefined


		initialize: (options) ->
			@_viewModel = options.viewModel
			@listenTo @_viewModel.highlightedGroupsCollection, 'reset', @_onHighlighedGroupsChange
			do @_viewModel.getHighlighedGroups

		render: ->
			templateData =
				title: @_viewModel.titleTranslationKey
				groups: @_viewModel.highlightedGroupsCollection.toJSON()

			@$el.html browseHighlightedTemplate(templateData)
			return @

		_onHighlighedGroupsChange: =>
			do @render

	Object.defineProperty BrowseHighlightedView.prototype, 'NAME',
		value: 'BrowseHighlightedView'


	return BrowseHighlightedView