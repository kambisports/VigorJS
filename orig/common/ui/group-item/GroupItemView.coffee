define (require) ->

	StringUtil = require 'utils/StringUtil'
	ComponentView = require 'common/ComponentView'
	tmpl = require 'hbs!./templates/GroupItem'

	class GroupItemView extends ComponentView

		tagName: 'li'
		className: 'modularized__event-groups__list-item'

		_viewModel: undefined

		initialize: (options) ->
			@_viewModel = options.viewModel
			super

		renderStaticContent: ->
			@$el.html tmpl(@_viewModel.group.toJSON())
			@$el.attr 'data-touch-feedback', 'true'

			@renderDeferred.resolve @
			return @

		renderDynamicContent: ->
			return

		addSubscriptions: ->
			return

		removeSubscriptions: ->
			return

		dispose: ->
			super

		# _buildPathtString: (groupId) ->
		# 	path = PathUtil.getPathForGroupId(groupId)

		# 	path.pop()

		# 	if path.length > 0
		# 		return _.reduce(path, (memo, obj) ->
		# 			"#{memo} / #{obj.name}"
		# 		, '').substr(3)
		# 	''

	GroupItemView