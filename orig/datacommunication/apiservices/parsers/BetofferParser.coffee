define (require) ->

	# TODO: verify betOfferType, closed, criterion

	{
		parse: (betoffer) ->
			betofferType: betoffer.betOfferType # object
			cashIn: betoffer.cashIn
			criterion: betoffer.criterion # object
			eventId: betoffer.eventId
			id: betoffer.id
			live: betoffer.live
			main: betoffer.main
			open: betoffer.open
			pba: betoffer.pba # object
			suspended: !!betoffer.suspended
			categoryName: betoffer.categoryName
			closed: !!betoffer.closed # boolean
	}