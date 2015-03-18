define ->
	ALL_EVENTS: 'all'

	# This event is sent when a route change
	ROUTE_CHANGE: 'route_change'

	# This event is sent when a new bet has been placed in the client
	BET_PLACED: 'bet-placed'

	# This event indicates a request to add one or more outcomes to the betslip
	ADD_OUTCOMES_TO_BETSLIP_REQUESTED: 'add-outcome-to-betslip-requested'

	# This event is sent when one or more outcomes have been added to the betslip
	OUTCOME_ADDED_TO_BETSLIP: 'outcome-added-to-betslip'

	# This event is sent when user clicks on menu button in the header
	TOGGLE_NAV_MENU: 'toggle-nav-menu'

	# This event is sent when a path util updates its state
	PATH_CHANGE: 'path-change'

	#### COMMUNICATION WITH OLD FACADE STUFF ####
	FACADE_PARSE_MOSTPOPULAR: 'facade-parse-mostpopular'