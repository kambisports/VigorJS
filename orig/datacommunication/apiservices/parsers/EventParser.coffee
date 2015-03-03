define (require) ->

	{
		parse: (eventObj) ->
			{
				id: eventObj.id # number
				homeName: eventObj.homeName #string
				awayName: eventObj.awayName #string
				group: eventObj.group #string
				groupId: eventObj.groupId #number
				englishName: eventObj.englishName #string
				hideStartNo: eventObj.hideStartNo #boolean
				liveBetoffers: eventObj.liveBetOffers #boolean
				name: eventObj.name #string
				open: eventObj.open #boolean from liveData property on live events
				openForLiveBetting: eventObj.openForLiveBetting #boolean
				path: eventObj.path #array
				sport: eventObj.sport #string
				sportId: eventObj.sportId #number
				start: eventObj.start #string "2015-02-10T23:00Z"
				state: eventObj.state #string "NOT_STARTED" "STARTED" "FINISHED"
				streams: eventObj.streams #array
				type: eventObj.type #string
			}
	}