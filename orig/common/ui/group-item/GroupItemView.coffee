define (require) ->

	PathUtil = require 'utils/PathUtil'
	StringUtil = require 'utils/StringUtil'
	ComponentView = require 'common/ComponentView'
	tmpl = require 'hbs!./templates/GroupItem'

	class GroupItemView extends ComponentView

		tagName: 'li'
		className: 'event-groups__list-item'

		_viewModel: undefined

		events:
			'click': '_onEventGroupClicked'

		initialize: (options) ->
			@_viewModel = options.viewModel
			super

		renderStaticContent: ->
			@$el.html tmpl
				name: StringUtil.toUpperCase(@_viewModel.group.get('name'))
				id: @_viewModel.group.get('id')
				path: this._buildPathtString(@_viewModel.group.get('id'))

			@$el.attr 'data-touch-feedback', 'true'

			@renderDeferred.resolve @
			@

		renderDynamicContent: ->
			return

		addSubscriptions: ->
			return

		removeSubscriptions: ->
			return

		dispose: ->
			super

		_buildPathtString: (groupId) ->
			path = PathUtil.getPathForGroupId(groupId)

			path.pop()

			if path.length > 0
				return _.reduce(path, (memo, obj) ->
					"#{memo} / #{obj.name}"
				, '').substr(3)
			''

		_onEventGroupClicked: () ->
			intEventId	= @_viewModel.group.get('id')
			strRoute = '#group/' + intEventId

			location.href = strRoute

	GroupItemView