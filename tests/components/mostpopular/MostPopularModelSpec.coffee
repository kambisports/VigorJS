define (require) ->

	MostPopularModel = require 'components/mostpopular/MostPopularModel'

	mostPopularModel = undefined
	deferredResponse = undefined
	mockedResponse =
    "events": [
        {
            "eventId": 1002329372,
            "betofferId": 2007918819
        },
        {
            "eventId": 1002329374,
            "betofferId": 2007918354
        },
        {
            "eventId": 1002263427,
            "betofferId": 2005990980
        },
        {
            "eventId": 1002263399,
            "betofferId": 2005990986
        },
        {
            "eventId": 1002263400,
            "betofferId": 2005990971
        }
    ],
    "selectedOutcomes": [
        {
            "outcomeId": 2028896587,
            "odds": 1000
        },
        {
            "outcomeId": 2028894715,
            "odds": 2000
        },
        {
            "outcomeId": 2021299028,
            "odds": 3000
        },
        {
            "outcomeId": 2021299043,
            "odds": 4000
        },
        {
            "outcomeId": 2021299007,
            "odds": 5000
        }
    ],
    "defaultStakes": [2, 5, 10, 25, 50, 100 ]

	describe 'MostPopularModel', ->
		beforeEach ->
			mostPopularModel = new MostPopularModel()

		afterEach ->
			mostPopularModel = undefined

		describe 'when having selected outcomes it', ->

			it 'should calculate combined odds', ->
				expect(mostPopularModel.selectedOutcomes.models.length).toEqual(0)
				expect(mostPopularModel.calculateCombinedOdds()).toEqual(0)

				mostPopularModel._storeData(mockedResponse)
				expect(mostPopularModel.selectedOutcomes.models.length).toEqual(5)
				expect(mostPopularModel.calculateCombinedOdds()).toEqual(120)
