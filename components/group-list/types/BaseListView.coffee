define (require) ->

	ComponentView = require 'common/ComponentView'
	GroupItem = require 'common/ui/group-item'
	EventGroupSortUtil = require 'utils/sort/EventGroupSortUtil'
	tmpl = require 'hbs!../templates/GroupList'

	class BaseListView extends ComponentView

		className: ''

		concatLimit: no

		_$showMore: undefined

		_listItems: undefined

		_showMoreClicked: no

		_sortingMethod: undefined

		#----------------------------------------------
		# Public methods
		#----------------------------------------------

		#----------------------------------------------
		# Overrides
		#----------------------------------------------

		initialize: (options) ->
			super
			@_sortingMethod = options.sortingMethod

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
		# Protected methods (override in subclass)
		#----------------------------------------------

		# Override this if data needs to be changed before render.
		getGroups: ->
			@viewModel.groups.models

		#----------------------------------------------
		# Private methods
		#----------------------------------------------

		# Call this when model has changed.
		_renderDynamicContent: ->
			@_clearDynamicContent()
			@_renderGroups @getGroups()

		# Clears all dynamically rendered content
		_clearDynamicContent: ->
			@_disposeGroups()

		_renderGroups: (groups, filter, sortAlphabetically) ->
			###
			# simulate changed data for first 3 groups
			groups[0]?.set({name: ''+Math.random()}, {silent: true})
			groups[1]?.set({name: ''+Math.random()}, {silent: true})
			groups[2]?.set({name: ''+Math.random()}, {silent: true})
			###

			if groups and groups.length

				#if @_sortingMethod is GroupListWidgetView2.SORTING_METHOD_HIGHLIGHTED_FIRST
				#	groups = EventGroupSortUtil.sortLeafEventGroups(groups, sortAlphabetically)

				eventGroupList = @$el.find '.event-groups__list'
				frag = document.createDocumentFragment()

				@_listItems = []

				for item, index in groups
					unless (filter and not filter(item))
						view = new GroupItem item
						@_listItems.push(view)
						view.render()
						view.$el.hide() if index >= @concatLimit unless @concatLimit is false
						frag.appendChild view.$el[0]
				
				@$el.find('.event-groups__list').html frag

				@_setExpandState groups.length

		_setExpandState: (nrOfGroups = 0) =>
			isBelowConcatLimit = nrOfGroups < @concatLimit
			if @_showMoreClicked
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

			# always render
			@_renderExpandState()
		
		_renderExpandState: =>
			if @viewModel.state.get('expanded')
				@_showAllGroups()

			if @viewModel.state.get('showMore')
				@_$showMore.show()
			else
				@_$showMore.hide()

		_showAllGroups: ->
			for item in @_listItems
				item.$el.show()

		_disposeGroups: ->
			_.each @_listItems, (view) ->
				view.dispose()
			@_listItems = undefined

		#----------------------------------------------
		# Callback methods
		#----------------------------------------------

		_onShowMoreClick: =>
			@_showMoreClicked = yes
			@_setExpandState()

		_onGroupsChange: =>
			@_renderDynamicContent()

	return BaseListView
