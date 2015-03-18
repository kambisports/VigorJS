define (require) ->

	ViewModel = require 'common/ViewModel'
	BreadcrumbItemCollection = require './BreadcrumbItemCollection'
	SubscriptionKeys = require 'datacommunication/SubscriptionKeys'

	class BreadcrumbViewModel extends ViewModel

		collection: new BreadcrumbItemCollection


		constructor: (options) ->
			super
			{@enableNewFrameworkLayout} = options


		addSubscriptions: ->
			if @enableNewFrameworkLayout
				@subscribe SubscriptionKeys.BREADCRUMB_ITEMS, @_onBreadcrumbItemsChange, {}
			else
				@subscribe SubscriptionKeys.BREADCRUMB_ITEMS_WITH_HOME, @_onBreadcrumbItemsChange, {}


		removeSubscriptions: ->
			@unsubscribe SubscriptionKeys.BREADCRUMB_ITEMS
			@unsubscribe SubscriptionKeys.BREADCRUMB_ITEMS_WITH_HOME


		resetItems: ->
			# Empty the collection
			do @collection.reset


		setItems: (arr) ->
			@collection.set arr


		_onBreadcrumbItemsChange: (data) =>
			if data?.length > 0
				@setItems data
			else
				do @resetItems
