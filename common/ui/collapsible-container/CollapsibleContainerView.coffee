define (require) ->

	ComponentView = require 'common/ComponentView'
	tmpl = require 'hbs!./templates/CollapsibleContainer'

	class CollapsibleContainerView extends ComponentView

		tagName: 'section'
		className: 'collapsible-container'

		$collapsibleHeader: undefined
		$collapsibleFooter: undefined
		$collapsibleContent: undefined

		_isExpanded: yes

		_viewModel: undefined


		constructor: (options) ->
			@_viewModel = options.viewModel
			super


		render: ->
			@$el.html tmpl
				title: @_viewModel.title

			@$collapsibleHeader = @$el.find '.collapsible-header'
			@$collapsibleFooter = @$el.find '.collapsible-footer'
			@$collapsibleContent = @$el.find '.collapsible-content'

			# set default expand state
			@_expand @isExpanded()

			@_bindEvents()

			@renderDeferred.resolve @
			return @


		isExpanded: ->
			@_isExpanded


		###
		getBreadCrumbsString: ->
			@headerString
		###


		setContent: (content) ->
			@$collapsibleContent.html content


		dispose: ->
			@_unbindEvents()

			@$collapsibleHeader = null
			@$collapsibleContent = null
			@$collapsibleFooter = null

			super


		_bindEvents: ->
			@$collapsibleHeader.on 'click', @_onHeaderClicked


		_unbindEvents: ->
			@$collapsibleHeader.off 'click', @_onHeaderClicked


		_expand: (value) ->
			@$el.toggleClass 'expanded', value
			@_isExpanded = value


		###
		# Tracks a page view for expanding or collapsing event group
		_trackExpandCollapse: (expanded) ->
			# override
			expanded
		###


		_onHeaderClicked: () =>
			@_expand !@_isExpanded
			

	return CollapsibleContainerView