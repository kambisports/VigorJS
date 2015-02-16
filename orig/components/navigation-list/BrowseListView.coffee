define (require) ->

	$ = require 'jquery'
	EventBus = require 'common/EventBus'
	EventKeys = require 'datacommunication/EventKeys'
	ComponentView = require 'common/ComponentView'
	TrackingUtil = require 'utils/TrackingUtil'
	listTemplate = require 'hbs!./templates/List'
	listItemTemplate = require 'hbs!./templates/ListItem'

	class BrowseHighlightedView extends ComponentView

		ACTIVE_CLASS = 'navigation-menu__section-link-anchor--active'

		tagName: 'section'
		className: 'navigation-menu__section navigation-menu__section--popular widget'

		_viewModel: undefined
		_radiogroup: undefined
		_$menuSection: undefined

		events:
			'click .js-nav-link': '_onNavLinkClick'

		initialize: (options) ->
			@_viewModel = options.viewModel
			@_radiogroup = @_viewModel.radiogroup
			@listenTo @_viewModel.itemsCollection, 'reset', @_onItemChange

		addSubscriptions: ->
			do @_viewModel.addSubscriptions
			EventBus.subscribe EventKeys.ROUTE_CHANGE, @_onRouteChange

		removeSubscriptions: ->
			do @_viewModel.removeSubscriptions
			EventBus.unsubcribe EventKeys.ROUTE_CHANGE, @_onRouteChange

		renderStaticContent: ->
			templateData =
				title: @_viewModel.titleTranslationKey
				radiogroup: @_viewModel.radiogroup or ''
				extraClassName: @_viewModel.extraClassName or ''

			@$el.html listTemplate(templateData)
			@_$menuSection = $ '.navigation-menu__section-links', @el

			return @

		renderDynamicContent: ->
			templateData =
				groups: @_viewModel.itemsCollection.toJSON() or []

			@_$menuSection.html listItemTemplate(templateData)

		dispose: ->
			@_viewModel = undefined
			@_radiogroup = undefined
			@_$menuSection = undefined
			super

		# ------------------------------------------------------------------------------------------------
		_clearRadioGroupActiveState: ->
			$radiogroup = $ "[data-radio-group='#{@_radiogroup}']"
			$('.js-nav-link', $radiogroup).removeClass ACTIVE_CLASS

		_setActiveState: (hash) ->
			do @_clearRadioGroupActiveState
			$activeRadioItem = $ ".js-nav-link[href='#{hash}']"
			$activeRadioItem.addClass ACTIVE_CLASS

		_trackNavigation: (trackingSignature) ->
			TrackingUtil.trackNavigationPanelLinkClick trackingSignature


		# ------------------------------------------------------------------------------------------------
		_onRouteChange: (route) =>
			hash = "##{route.fragment}"
			@_setActiveState hash

		_onItemChange: =>
			do @renderDynamicContent

		_onNavLinkClick: (event) =>
			trackingSignature = $(event.currentTarget).data 'tracking'
			@_trackNavigation trackingSignature

	return BrowseHighlightedView