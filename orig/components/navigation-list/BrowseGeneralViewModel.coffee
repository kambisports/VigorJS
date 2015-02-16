define (require) ->

	Backbone = require 'lib/backbone'
	ViewModel = require 'common/ViewModel'
	SubscriptionKeys = require 'datacommunication/SubscriptionKeys'
	LocaleUtil = require 'utils/LocaleUtil'
	FormatUtil = require 'utils/FormatUtil'

	# ----------------------------------------------------------------------------------------------------
	class BrowseGeneralViewModel extends ViewModel

		TRACKING_PREFIX = 'Browse'
		STARTS_WITHIN_MINUTES = [15, 60]

		id: 'BrowseGeneralViewModel'
		titleTranslationKey: 'navigationMenu.browse'

		radiogroup: undefined
		itemsCollection: undefined
		extraClassName: 'visuallyhidden'

		# ------------------------------------------------------------------------------------------------
		constructor: ->
			links = _getStaticLinks(0)
			@itemsCollection = new Backbone.Collection links
			super

		addSubscriptions: ->
			@subscribe SubscriptionKeys.LIVE_EVENTS, @_onNewLiveEvents, {}

		removeSubscriptions: ->
			@unsubscribe SubscriptionKeys.LIVE_EVENTS

		# ------------------------------------------------------------------------------------------------
		_getStaticLinks = (liveRightNowCount) ->
			linksDataArray = []
			showAllSportsLink = _getHomeLink()
			liveRightNowLink = _getLiveRightNowLink(liveRightNowCount)
			startsWithinLinks = _getStartsWithinLinks()

			linksDataArray.push showAllSportsLink
			if liveRightNowLink
				linksDataArray.push liveRightNowLink

			linksDataArray = linksDataArray.concat linksDataArray, startsWithinLinks
			return linksDataArray

		_getHomeLink = ->
			name = LocaleUtil.getTranslation 'home'
			homeData =
				id: 'show-all-sports'
				name: name
				url: '#home'
				trackingSignature: "#{TRACKING_PREFIX} - Live Right Now"
				title: name

			return homeData

		_getLiveRightNowLink = (count) ->
			if count is 0 then return false
			liveLabel = LocaleUtil.getTranslation 'liveCarousel.liveLabel'
			rightNowLabel = LocaleUtil.getTranslation 'liveCarousel.rightNowLabel'
			liveEventsName = "<em class='navigation-menu__section-link-event-label__now'>#{liveLabel}</em> #{rightNowLabel}"

			liveRightNowData =
				id: 'live-right-now'
				name: liveEventsName
				title: "#{liveLabel} #{rightNowLabel}"
				boCount: count
				extraClassName: 'navigation-menu__section-link-anchor--liverightnow'
				url: '#events/live'
				trackingSignature: "#{TRACKING_PREFIX} - Live Right Now"

			return liveRightNowData

		_getStartsWithinLinks = ->
			startsWithinLinksData = []

			for minutes in STARTS_WITHIN_MINUTES
				startsWithinData =
					id: "starts-within-#{minutes}"
					name: FormatUtil.minutesToStartsWithinText(minutes)
					url: "#starts-within/#{minutes}"
					trackingSignature: "#{TRACKING_PREFIX} - Starts within #{minutes} minutes"
					title: FormatUtil.minutesToStartsWithinText(minutes)

				startsWithinLinksData.push startsWithinData

			return startsWithinLinksData

		# ------------------------------------------------------------------------------------------------
		_onNewLiveEvents: (liveEvents) =>
			@itemsCollection.reset _getStaticLinks(liveEvents.length)

	BrowseGeneralViewModel
