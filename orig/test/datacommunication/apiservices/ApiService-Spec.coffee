define (require) ->

	ApiService = require 'datacommunication/apiservices/ApiService'
	_ = require 'lib/underscore'

	apiService = undefined
	windowStub = undefined

	class DateStub
		constructor: ->
			@time = 0
		setNow: (@time) ->
		now: -> @time

	class WindowStub
		constructor: ->
			@Date = new DateStub()
			@setTimeout = jasmine.createSpy 'setTimeout'
			@clearTimeout = jasmine.createSpy 'clearTimeout'

	describe 'An ApiService', ->

		beforeEach ->
			windowStub = new WindowStub()
			apiService = new ApiService(windowStub)

		describe 'handles subscriptions', ->
			it 'creates channels', ->

				(spyOn apiService, 'channelForParams').andCallFake -> 'test'
				
				apiService.addSubscription {}

				(expect (_.keys apiService.channels).length).toBe 1
				(expect apiService.channels['test']).toBeDefined()

			it 'creates multiple channels', ->
				params1 = {}
				params2 = {}

				(spyOn apiService, 'channelForParams').andCallFake (params) ->
					switch params
						when params1 then '1'
						when params2 then '2'
						else ''

				apiService.addSubscription
					params: params1

				apiService.addSubscription
					params: params2

				(expect (_.keys apiService.channels).length).toBe 2
				(expect apiService.channels['1']).toBeDefined()
				(expect apiService.channels['2']).toBeDefined()

			it 'removes channels', ->
				subscription = {}

				(spyOn apiService, 'channelForParams').andCallFake -> 'test'

				apiService.addSubscription subscription
				apiService.removeSubscription subscription

				(expect (_.keys apiService.channels).length).toBe 0

			it 'removes channels by params reference', ->
				subscription1 = {}
				subscription2 = {}

				(spyOn apiService, 'channelForParams').andCallFake -> 'test'

				apiService.addSubscription subscription1
				apiService.removeSubscription subscription2

				(expect (_.keys apiService.channels).length).toBe 1

			it 'does not remove a channel if there is still a subscriber', ->
				subscription1 = {}
				subscription2 = {}

				(spyOn apiService, 'channelForParams').andCallFake -> 'test'

				apiService.addSubscription subscription1
				apiService.addSubscription subscription2

				apiService.removeSubscription subscription1

				(expect (_.keys apiService.channels).length).toBe 1

			it 'removes a channel even if other channels exist', ->

				subscription1 = {}
				subscription2 = {}

				(spyOn apiService, 'channelForParams').andCallFake -> 'test'

				apiService.addSubscription subscription1
				apiService.addSubscription subscription2

				apiService.removeSubscription subscription1

				(expect (_.keys apiService.channels).length).toBe 1


		describe 'returns the channel for params', ->
			it 'is passed the params', ->
				spyOn apiService, 'channelForParams'

				params = {}

				apiService.addSubscription
					params: params

				(expect apiService.channelForParams.calls.length).toBe 1
				args = apiService.channelForParams.mostRecentCall.args

				# args are params
				(expect args.length).toBe 1
				(expect args[0]).toBe params

			it 'returns the stringified params by default', ->
				
				params = {
					foo: 'bar'
				}

				channel = apiService.channelForParams params
				(expect channel).toBe JSON.stringify params

			it 'returns the stringified empty object for null params', ->

				channelForUndefined = apiService.channelForParams undefined
				channelForEmpty = apiService.channelForParams {}

				(expect channelForUndefined).toBe channelForEmpty

			it 'returns the same channel regardless of key order', ->
				channel1 = apiService.channelForParams
					a: [3,1,5]
					c:
						e: 'bar'
						d: 'foo'
					b: 'foo'
					f: [
						{
							g: 'g'
						}
						{
							h: 'h'
						}
					]

				channel2 = apiService.channelForParams
					b: 'foo'
					a: [5,1,3]
					f: [
						{
							h: 'h'
						}
						{
							g: 'g'
						}
					]
					c:
						d: 'foo'
						e: 'bar'

				(expect channel1).toBe channel2

		describe 'consolidates params', ->
			it 'is passed the a single param', ->
				spyOn apiService, 'consolidateParams'

				params = {}

				apiService.addSubscription
					params: params

				(expect apiService.consolidateParams.calls.length).toBe 1
				args = apiService.consolidateParams.mostRecentCall.args
				
				# args are params array, channel name
				(expect args.length).toBe 2
				
				# check params
				(expect args[0].length).toBe 1
				(expect args[0][0]).toBe params

				# channel name
				(expect args[1]).toBe '{}'

			it 'is passed multiple params', ->
				spyOn apiService, 'consolidateParams'

				params1 = {}
				params2 = {}

				apiService.addSubscription
					params: params1

				apiService.addSubscription
					params: params2

				# one call for each time a subscription was added
				(expect apiService.consolidateParams.calls.length).toBe 2
				args = apiService.consolidateParams.mostRecentCall.args
				
				# check params
				(expect args[0].length).toBe 2
				(expect args[0][0]).toBe params1
				(expect args[0][1]).toBe params2

			it 'returns the first params by default', ->
				firstParams = {}
				result = apiService.consolidateParams [firstParams, {}]
				(expect result).toBe firstParams

		describe 'returns whether to fetch on params update', ->
			it 'returns true by default', ->
				shouldFetch = apiService.shouldFetchOnParamsUpdate()
				(expect shouldFetch).toBe true

		describe 'fetches data', ->
			it 'does one-off fetches', ->
				params = {}

				(spyOn apiService, 'consolidateParams').andCallFake -> params
				spyOn apiService, 'fetch'

				apiService.addSubscription
					params: params

				(expect windowStub.setTimeout.calls.length).toBe 1
				args = windowStub.setTimeout.mostRecentCall.args
				(expect args.length).toBe 2
				(expect args[1]).toBe 0
				callback = args[0]

				callback()

				(expect apiService.fetch.calls.length).toBe 1
				(expect (_.keys apiService.services).length).toBe 0
				
			it 'does polled fetches', ->
				params = {}
				pollingInterval = 100

				(spyOn apiService, 'consolidateParams').andCallFake -> params
				spyOn apiService, 'fetch'

				apiService.addSubscription
					pollingInterval: pollingInterval
					params: params

				(expect windowStub.setTimeout.calls.length).toBe 1
				args = windowStub.setTimeout.mostRecentCall.args
				(expect args.length).toBe 2
				(expect args[1]).toBe 0
				callback = args[0]

				callback()

				(expect windowStub.setTimeout.calls.length).toBe 2
				args = windowStub.setTimeout.mostRecentCall.args
				(expect args.length).toBe 2
				(expect args[1]).toBe pollingInterval
				callback = args[0]

				callback()

				(expect apiService.fetch.calls.length).toBe 2
				(expect (_.keys apiService.services).length).toBe 0

				(expect windowStub.setTimeout.calls.length).toBe 3

			it 'asks whether to fetch immediately when params change', ->
				params1 = {}
				params2 = {}
				pollingInterval = 100
				channelName = 'test'

				consolidatedParams = [
					{
						foo: 'bar'
					},
					{
						baz: 'qux'
					}
				]

				# params must change
				(spyOn apiService, 'consolidateParams').andCallFake (params) ->
					consolidatedParams[params.length - 1]

				(spyOn apiService, 'channelForParams').andCallFake -> channelName

				spyOn apiService, 'fetch'

				spyOn apiService, 'shouldFetchOnParamsUpdate'

				apiService.addSubscription
					pollingInterval: pollingInterval
					params: params1

				callback = windowStub.setTimeout.mostRecentCall.args[0]
				callback()

				apiService.addSubscription
					pollingInterval: pollingInterval
					params: params2

				(expect apiService.shouldFetchOnParamsUpdate.calls.length).toBe 1

				args = apiService.shouldFetchOnParamsUpdate.mostRecentCall.args
				(expect _.isEqual args[0], consolidatedParams[1]).toBe true
				(expect _.isEqual args[1], consolidatedParams[0]).toBe true
				(expect args[2]).toBe channelName

			it 'fetches immediately when params change if shouldFetchOnParamsUpdate is true', ->
				params1 = {}
				params2 = {}
				pollingInterval = 100
				channelName = 'test'

				consolidatedParams = [
					{
						foo: 'bar'
					},
					{
						baz: 'qux'
					}
				]

				# params must change
				(spyOn apiService, 'consolidateParams').andCallFake (params) ->
					consolidatedParams[params.length - 1]

				(spyOn apiService, 'channelForParams').andCallFake -> channelName

				spyOn apiService, 'fetch'

				(spyOn apiService, 'shouldFetchOnParamsUpdate').andCallFake -> true

				apiService.addSubscription
					pollingInterval: pollingInterval
					params: params1

				callback = windowStub.setTimeout.mostRecentCall.args[0]
				callback()

				apiService.addSubscription
					pollingInterval: pollingInterval
					params: params2

				timeout = windowStub.setTimeout.mostRecentCall.args[1]
				(expect timeout).toBe 0

			it 'does not fetch immediately when params change if shouldFetchOnParamsUpdate is false', ->
				params1 = {}
				params2 = {}
				pollingInterval = 100
				channelName = 'test'

				consolidatedParams = [
					{
						foo: 'bar'
					},
					{
						baz: 'qux'
					}
				]

				# params must change
				(spyOn apiService, 'consolidateParams').andCallFake (params) ->
					consolidatedParams[params.length - 1]

				(spyOn apiService, 'channelForParams').andCallFake -> channelName

				spyOn apiService, 'fetch'

				(spyOn apiService, 'shouldFetchOnParamsUpdate').andCallFake -> false

				apiService.addSubscription
					pollingInterval: pollingInterval
					params: params1

				callback = windowStub.setTimeout.mostRecentCall.args[0]
				callback()

				apiService.addSubscription
					pollingInterval: pollingInterval
					params: params2

				timeout = windowStub.setTimeout.mostRecentCall.args[1]
				(expect timeout).toBe 100

			it 'does not ask to fetch immediately if params did not change', ->
				params1 = {}
				params2 = {}
				pollingInterval = 100
				channelName = 'test'

				(spyOn apiService, 'consolidateParams').andCallFake -> {}

				(spyOn apiService, 'channelForParams').andCallFake -> channelName

				spyOn apiService, 'fetch'

				(spyOn apiService, 'shouldFetchOnParamsUpdate').andCallFake -> false

				apiService.addSubscription
					pollingInterval: pollingInterval
					params: params1

				callback = windowStub.setTimeout.mostRecentCall.args[0]
				callback()

				apiService.addSubscription
					pollingInterval: pollingInterval
					params: params2

				(expect apiService.shouldFetchOnParamsUpdate.calls.length).toBe 0

			it 'does not ask to fetch immediately if params change on different channels', ->

				params1 = {}
				params2 = {}
				pollingInterval = 100
				channelName = 'test'

				(spyOn apiService, 'consolidateParams').andCallFake (params) ->
					switch params[0]
						when params1 then { foo: 'bar' }
						when params2 then { baz: 'qux' }
						else {}

				(spyOn apiService, 'channelForParams').andCallFake (params) ->
					switch params
						when params1 then '1'
						when params2 then '2'
						else ''

				spyOn apiService, 'fetch'

				(spyOn apiService, 'shouldFetchOnParamsUpdate').andCallFake -> false

				apiService.addSubscription
					pollingInterval: pollingInterval
					params: params1

				callback = windowStub.setTimeout.mostRecentCall.args[0]
				callback()

				apiService.addSubscription
					pollingInterval: pollingInterval
					params: params2

				(expect apiService.shouldFetchOnParamsUpdate.calls.length).toBe 0

			it 'updates the polling interval to the most frequent rate', ->

				params1 = {}
				params2 = {}
				pollingInterval1 = 100
				pollingInterval2 = 50

				(spyOn apiService, 'consolidateParams').andCallFake -> params1

				(spyOn apiService, 'channelForParams').andCallFake -> 'test'

				spyOn apiService, 'fetch'

				(spyOn apiService, 'shouldFetchOnParamsUpdate').andCallFake -> true

				apiService.addSubscription
					pollingInterval: pollingInterval1
					params: params1

				callback = windowStub.setTimeout.mostRecentCall.args[0]
				callback()

				# the timeout for the first callback is always 0. Repetition sidesteps that case
				callback = windowStub.setTimeout.mostRecentCall.args[0]
				callback()

				apiService.addSubscription
					pollingInterval: pollingInterval2
					params: params2

				timeout = windowStub.setTimeout.mostRecentCall.args[1]
				(expect timeout).toBe 50

			it 'does not update the polling interval if the new value is less frequent', ->

				params1 = {}
				params2 = {}
				pollingInterval1 = 50
				pollingInterval2 = 100

				(spyOn apiService, 'consolidateParams').andCallFake -> params1

				(spyOn apiService, 'channelForParams').andCallFake -> 'test'

				spyOn apiService, 'fetch'

				(spyOn apiService, 'shouldFetchOnParamsUpdate').andCallFake -> true

				apiService.addSubscription
					pollingInterval: pollingInterval1
					params: params1

				callback = windowStub.setTimeout.mostRecentCall.args[0]
				callback()

				# the timeout for the first callback is always 0. Repetition sidesteps that case
				callback = windowStub.setTimeout.mostRecentCall.args[0]
				callback()

				timeout = windowStub.setTimeout.mostRecentCall.args[1]
				(expect timeout).toBe 50

				apiService.addSubscription
					pollingInterval: pollingInterval2
					params: params2

				timeout = windowStub.setTimeout.mostRecentCall.args[1]
				(expect timeout).toBe 50

			it 'passes the correct remaining timeout when the polling interval changes', ->

				params1 = {}
				params2 = {}
				pollingInterval1 = 100
				pollingInterval2 = 50

				elapsedTime = 20
				remainingTime = pollingInterval2 - elapsedTime

				(spyOn apiService, 'consolidateParams').andCallFake -> params1

				(spyOn apiService, 'channelForParams').andCallFake -> 'test'

				spyOn apiService, 'fetch'

				(spyOn apiService, 'shouldFetchOnParamsUpdate').andCallFake -> true

				apiService.addSubscription
					pollingInterval: pollingInterval1
					params: params1

				callback = windowStub.setTimeout.mostRecentCall.args[0]
				callback()

				# the timeout for the first callback is always 0. Repetition sidesteps that case
				callback = windowStub.setTimeout.mostRecentCall.args[0]
				callback()

				windowStub.Date.setNow 20

				apiService.addSubscription
					pollingInterval: pollingInterval2
					params: params2

				timeout = windowStub.setTimeout.mostRecentCall.args[1]
				(expect timeout).toBe remainingTime


			it 'passes the correct remaining timeout when interval does not update', ->

				params1 = {}
				params2 = {}
				pollingInterval = 100

				remainingTime = pollingInterval

				(spyOn apiService, 'consolidateParams').andCallFake (params) ->
					switch params[0]
						when params1 then { foo: 'bar' }
						when params2 then { baz: 'qux' }
						else {}

				(spyOn apiService, 'channelForParams').andCallFake -> 'test'

				spyOn apiService, 'fetch'

				(spyOn apiService, 'shouldFetchOnParamsUpdate').andCallFake -> true

				apiService.addSubscription
					pollingInterval: pollingInterval
					params: params1

				callback = windowStub.setTimeout.mostRecentCall.args[0]
				callback()

				# the timeout for the first callback is always 0. Repetition sidesteps that case
				callback = windowStub.setTimeout.mostRecentCall.args[0]
				callback()

				windowStub.Date.setNow 20

				apiService.addSubscription
					pollingInterval: pollingInterval
					params: params2

				timeout = windowStub.setTimeout.mostRecentCall.args[1]
				(expect timeout).toBe remainingTime

		describe 'fetches data', ->

			describe 'default model', ->
				it 'syncs', ->
					model = new apiService.Model()
					spyOn apiService, 'sync'

					method = 'GET'
					model = model
					options = {}

					model.sync method, model, options

					(expect apiService.sync.calls.length).toBe 1
					args = apiService.sync.mostRecentCall.args
					(expect args.length).toBe 3
					(expect args[0]).toBe method
					(expect args[1]).toBe model
					(expect args[2]).toBe options
					(expect apiService.sync.mostRecentCall.object).toBe apiService

				it 'gets the URL', ->
					model = new apiService.Model()
					spyOn apiService, 'url'

					model.url()

					(expect apiService.url.calls.length).toBe 1
					args = apiService.url.mostRecentCall.args
					(expect args.length).toBe 1
					(expect args[0]).toBe model
					(expect apiService.url.mostRecentCall.object).toBe apiService

				it 'parses the response', ->
					model = new apiService.Model()
					spyOn apiService, 'parse'

					response = {}
					options = {}
					model.parse response, options

					(expect apiService.parse.calls.length).toBe 1
					args = apiService.parse.mostRecentCall.args
					(expect args.length).toBe 3
					(expect args[0]).toBe response
					(expect args[1]).toBe options
					(expect args[2]).toBe model
					(expect apiService.parse.mostRecentCall.object).toBe apiService

				it 'can be overridden by getModelInstance', ->
					model = new Backbone.Model
					model.fetch = jasmine.createSpy()

					apiService.getModelInstance = -> model

					consolidatedParams = {}

					apiService.onFetchSuccess = (->)
					apiService.onFetchError = (->)

					callbacks =
						success: apiService.onFetchSuccess
						error: apiService.onFetchError

					apiService.fetch consolidatedParams

					(expect model.fetch.calls.length).toBe 1
					args = model.fetch.mostRecentCall.args
					(expect _.isEqual args[0], callbacks).toBe true


			it 'calls fetch on the service', ->
				
				consolidatedParams = {}

				(spyOn apiService, 'consolidateParams').andReturn consolidatedParams
				spyOn apiService, 'fetch'

				apiService.addSubscription {}

				callback = windowStub.setTimeout.mostRecentCall.args[0]
				callback()

				(expect apiService.fetch.calls.length).toBe 1

				args = apiService.fetch.mostRecentCall.args
				(expect args[0]).toBe consolidatedParams

			it 'calls fetch on the model', ->

				consolidatedParams = {}

				modelFetch = jasmine.createSpy()

				(spyOn apiService, 'getModelInstance').andCallFake (params) ->
					(expect params).toBe consolidatedParams
					model = new Backbone.Model params
					model.fetch = modelFetch
					model

				apiService.onFetchSuccess = (->)
				apiService.onFetchError = (->)

				callbacks =
					success: apiService.onFetchSuccess
					error: apiService.onFetchError

				apiService.fetch consolidatedParams

				(expect modelFetch.calls.length).toBe 1
				args = modelFetch.mostRecentCall.args
				(expect _.isEqual args[0], callbacks).toBe true

