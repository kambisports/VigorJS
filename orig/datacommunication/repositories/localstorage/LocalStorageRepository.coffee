define (require) ->
	require 'localstorage'

	class LocalStorageRepository extends Backbone.Model

		localStorage: new Backbone.LocalStorage('kambi-localstorage')

		KEY_BETSLIP = 'key_betslip'
		KEY_DEEPLINK = 'key_deeplink'
		KEY_STARRED = 'key_starred'
		KEY_PBA_SELECTION = 'key_pba_selection'
		KEY_LEAGUE_VIEW_LAST_EVENT_GROUP = 'key_league_view_last_event_group'
		KEY_ODDS_FORMAT = 'key_odds_format'
		KEY_RETAIN_BETSLIP_SELECTION = 'key_retain_betslip_selection'
		KEY_PUNTER_SETTING = 'key_punter_setting'
		KEY_USER_SETTING = 'key_user_setting'
		KEY_POOL = 'key_pool'


		defaults:
			id: 'all'
			debug: undefined
			key_betslip: undefined
			key_deeplink: undefined
			key_starred: undefined
			key_pba_selection: undefined
			key_league_view_last_event_group: undefined
			key_odds_format: undefined
			key_retain_betslip_selection: undefined
			key_punter_setting: undefined
			key_user_setting: undefined
			key_pool: undefined
		#---------------------------------------------------------------------
		#	Public methods
		#---------------------------------------------------------------------
		initialize: ->
			do @fetch

		query: (key) ->
			value = @get(key)
			if value then value = JSON.parse(value)
			return value


		queryBetslip: ->
			return @query(KEY_BETSLIP)

		queryDeeplink: ->
			return @query(KEY_DEEPLINK)

		queryStarred: ->
			return @query(KEY_STARRED)

		queryPBASelection: ->
			return @query(KEY_PBA_SELECTION)

		queryLeagueViewLastEventGroup: ->
			return @query(KEY_LEAGUE_VIEW_LAST_EVENT_GROUP)

		queryOddsFormat: ->
			return @query(KEY_ODDS_FORMAT)

		queryRetainBetslipSelection: ->
			return @query(KEY_RETAIN_BETSLIP_SELECTION)

		queryPunterSettings: ->
			return @query(KEY_PUNTER_SETTING)

		queryUserSettings: ->
			return @query(KEY_USER_SETTING)

		queryPool: ->
			return @query(KEY_POOL)

		NAME: 'LocalStorageRepository'

	return new LocalStorageRepository()