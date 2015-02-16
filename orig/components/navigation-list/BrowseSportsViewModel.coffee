define (require) ->

	Backbone = require 'lib/backbone'
	ViewModel = require 'common/ViewModel'
	SubscriptionKeys = require 'datacommunication/SubscriptionKeys'
	LocaleUtil = require 'utils/LocaleUtil'

	# ----------------------------------------------------------------------------------------------------
	class BrowseSportsViewModel extends ViewModel

		TRACKING_PREFIX = 'Sport'
		itemsCollection: undefined
		id: 'BrowseSportsViewModel'
		titleTranslationKey: 'startpage.atoz'

		# ------------------------------------------------------------------------------------------------

		constructor: ->
			@itemsCollection = new Backbone.Collection()
			super

		addSubscriptions: ->
			@subscribe SubscriptionKeys.PERSONALIZED_SPORTS, @_onNewGroups, {}

		removeSubscriptions: ->
			@unsubscribe SubscriptionKeys.PERSONALIZED_SPORTS


		# ------------------------------------------------------------------------------------------------
		_decorateData: (sportsJson) ->
			for sport in sportsJson
				sport.trackingSignature = "#{TRACKING_PREFIX} - #{sport.englishName}"
				sport.title = sport.englishName
			return sportsJson

		_storeData: (topSportsData) =>
			topSports = topSportsData.topSports
			sportsCount = topSportsData.totalSportsCount

			topSports = @_decorateData(topSports)
			topSports.push @_createShowMoreSportsModel(sportsCount)
			@itemsCollection.reset topSports

		_createShowMoreSportsModel: (sportsCount) ->
			name = LocaleUtil.getTranslation('locale.navigation.showAllSports')
			data =
				boCount: sportsCount
				id: 'show-all-sports'
				name: name
				title: name
				url: '#sports/a-z'
				extraClassName: 'navigation-menu__section-link-anchor--allsports'
				trackingSignature: "#{TRACKING_PREFIX} - Show all sports"

			return data
		# ------------------------------------------------------------------------------------------------

		_onNewGroups: (topSportsData) =>
			@_storeData topSportsData

	BrowseSportsViewModel
