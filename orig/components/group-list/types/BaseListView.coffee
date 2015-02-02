define (require) ->

	ComponentView = require 'common/ComponentView'
	GroupItem = require 'common/ui/group-item'
	EventGroupSortUtil = require 'utils/sort/EventGroupSortUtil'
	tmpl = require 'hbs!../templates/GroupList'

	class BaseListView extends ComponentView

		className: ''

		concatLimit: no

		_$showMore: undefined

		# Array of all current GroupItem components
		_groupItemList: undefined

		#----------------------------------------------
		# Public methods
		#----------------------------------------------

		#----------------------------------------------
		# Overrides
		#----------------------------------------------

		initialize: (options) ->
			super
			@listenTo @viewModel.state, 'change:expanded', @_renderExpandState
			@listenTo @viewModel.groups, 'reset', @_onGroupsChange

		renderStaticContent: ->
			@$el.html tmpl
				showMoreLocalized: 'common.moresports'

			@_$showMore = @$el.find '.event-group-show-more'
			@_$showMore.hide()
			@_$showMore?.on 'click', @_onShowMoreClick

			return @

		addSubscriptions: ->
			@viewModel.addSubscriptions()

		removeSubscriptions: ->
			@viewModel.removeSubscriptions()

		dispose: ->
			@stopListening @viewModel.state, 'change:expanded', @_renderExpandState
			@stopListening @viewModel.groups, 'reset', @_onGroupsChange

			@_$showMore?.off 'click', @_onShowMoreClick

			@_disposeGroups()
			super

		#----------------------------------------------
		# Private methods
		#----------------------------------------------

		# Call this when model has changed.
		_renderDynamicContent: ->
			@_clearDynamicContent()
			@_renderGroups @viewModel.getGroups()

		# Clears all dynamically rendered content
		_clearDynamicContent: ->
			@_disposeGroups()

		_renderGroups: (groups) ->
			if groups and groups.length

				eventGroupList = @$el.find '.event-groups__list'
				frag = document.createDocumentFragment()

				@_groupItemList = []

				for group, index in groups
					view = new GroupItem group
					@_groupItemList.push(view)
					view.render()
					view.$el.hide() if index >= @concatLimit unless @concatLimit is false
					frag.appendChild view.$el[0]

				@$el.find('.event-groups__list').html frag

				@_setExpandState groups.length

		_setExpandState: (nrOfGroups = 0) =>
			isBelowConcatLimit = nrOfGroups <= @concatLimit
			showMoreClicked = @viewModel.state.get 'showMoreClicked'

			if showMoreClicked
				expanded = yes
				showMore = no
			else if not @concatLimit or isBelowConcatLimit
				expanded = yes
				showMore = no
			else
				expanded = no
				showMore = yes

			@viewModel.state.set
				expanded: expanded
				showMore: showMore,
			silent: yes

			# always render after set
			@_renderExpandState()

		_renderExpandState: =>
			if @viewModel.state.get('expanded')
				@_showAllGroups()

			if @viewModel.state.get('showMore')
				@_$showMore.show()
			else
				@_$showMore.hide()

		_showAllGroups: ->
			for groupItem in @_groupItemList
				groupItem.$el.show()

		_disposeGroups: ->
			_.each @_groupItemList, (groupItem) ->
				groupItem.dispose()
				groupItem = undefined
			@_groupItemList = undefined

		#----------------------------------------------
		# Callback methods
		#----------------------------------------------

		_onShowMoreClick: =>
			@viewModel.state.set
				showMoreClicked: yes,
			silent: yes

			@_setExpandState()

		_onGroupsChange: =>
			@_renderDynamicContent()

	return BaseListView
