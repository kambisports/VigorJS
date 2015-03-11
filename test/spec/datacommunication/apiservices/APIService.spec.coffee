Vigor = require '../../../../dist/backbone.vigor'
assert = require 'assert'
sinon = require 'sinon'
sandbox = undefined

APIService = Vigor.APIService
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
    @setTimeout = sinon.spy()
    @clearTimeout = sinon.spy()

describe 'An ApiService', ->

  beforeEach ->
    windowStub = new WindowStub()
    apiService = new Vigor.APIService(windowStub)

  describe 'handles subscriptions', ->
    it 'creates channels', ->

      sinon.stub apiService, 'channelForParams', -> 'test'
      apiService.addSubscription {}
      assert.equal _.keys(apiService.channels).length, 1
      assert.ok apiService.channels['test']

    it 'creates multiple channels', ->
      params1 = {}
      params2 = {}

      sinon.stub apiService, 'channelForParams', (params) ->
        switch params
          when params1 then '1'
          when params2 then '2'
          else ''

      apiService.addSubscription
        params: params1

      apiService.addSubscription
        params: params2

      assert.equal _.keys(apiService.channels).length, 2
      assert.ok apiService.channels['1']
      assert.ok apiService.channels['2']

    it 'removes channels', ->
      subscription = {}

      sinon.stub apiService, 'channelForParams', -> 'test'

      apiService.addSubscription subscription
      apiService.removeSubscription subscription

      assert.equal _.keys(apiService.channels).length, 0

    it 'removes channels by params reference', ->
      subscription1 = {}
      subscription2 = {}

      sinon.stub apiService, 'channelForParams', -> 'test'

      apiService.addSubscription subscription1
      apiService.removeSubscription subscription2

      assert.equal _.keys(apiService.channels).length, 1

    it 'does not remove a channel if there is still a subscriber', ->
      subscription1 = {}
      subscription2 = {}

      sinon.stub apiService, 'channelForParams', -> 'test'

      apiService.addSubscription subscription1
      apiService.addSubscription subscription2

      apiService.removeSubscription subscription1

      assert.equal _.keys(apiService.channels).length, 1

    it 'removes a channel even if other channels exist', ->
      subscription1 = {}
      subscription2 = {}

      sinon.stub apiService, 'channelForParams', -> 'test'

      apiService.addSubscription subscription1
      apiService.addSubscription subscription2

      apiService.removeSubscription subscription1

      assert.equal _.keys(apiService.channels).length, 1


  describe 'returns the channel for params', ->
    it 'is passed the params', ->
      spy = sinon.spy apiService, 'channelForParams'

      params = {}

      apiService.addSubscription
        params: params

      assert spy.withArgs(params).calledOnce

    it 'returns the stringified params by default', ->
      params =
        foo: 'bar'

      channel = apiService.channelForParams params
      assert.equal channel, JSON.stringify params

    it 'returns the stringified empty object for null params', ->
      channelForUndefined = apiService.channelForParams undefined
      channelForEmpty = apiService.channelForParams {}

      assert.equal channelForUndefined, channelForEmpty

  describe 'consolidates params', ->
    it 'is passed the a single param', ->
      spy = sinon.spy apiService, 'consolidateParams'

      params = {}

      apiService.addSubscription
        params: params

      assert spy.calledOnce

      args = spy.lastCall.args

      # args are params array, channel name
      assert.equal args.length, 2

      # check params
      assert.equal args[0].length, 1
      assert.equal args[0][0], params

      # channel name
      assert.equal args[1], '{}'


    it 'is passed multiple params', ->
      spy = sinon.spy apiService, 'consolidateParams'

      params1 = {}
      params2 = {}

      apiService.addSubscription
        params: params1

      apiService.addSubscription
        params: params2

      # one call for each time a subscription was added
      assert spy.calledTwice
      args = spy.lastCall.args

      # check params
      assert.equal args[0].length, 2
      assert.equal args[0][0], params1
      assert.equal args[0][1], params2

    it 'returns the first params by default', ->
      firstParams = {}
      result = apiService.consolidateParams [firstParams, {}]
      assert.equal result, firstParams

  describe 'returns whether to fetch on params update', ->
    it 'returns true by default', ->
      shouldFetch = apiService.shouldFetchOnParamsUpdate()
      assert.ok shouldFetch

  describe 'fetches data', ->
    it 'does one-off fetches', ->
      params = {}

      consolidateParams = sinon.stub apiService, 'consolidateParams', -> params
      fetch = sinon.stub apiService, 'fetch'

      apiService.addSubscription
        params: params

      assert windowStub.setTimeout.calledOnce
      args = windowStub.setTimeout.lastCall.args

      assert.equal args.length, 2
      assert.equal args[1], 0
      callback = args[0]

      callback()

      assert fetch.calledOnce
      assert.equal _.keys(apiService.services).length, 0

    it 'does polled fetches', ->
      params = {}
      pollingInterval = 100

      consolidateParams = sinon.stub apiService, 'consolidateParams', -> params
      fetch = sinon.stub apiService, 'fetch'

      apiService.addSubscription
        pollingInterval: pollingInterval
        params: params

      assert windowStub.setTimeout.calledOnce
      args = windowStub.setTimeout.lastCall.args

      assert.equal args.length, 2
      assert.equal args[1], 0
      callback = args[0]

      callback()

      assert windowStub.setTimeout.calledTwice
      args = windowStub.setTimeout.lastCall.args

      assert.equal args.length, 2
      assert.equal args[1], pollingInterval
      callback = args[0]

      callback()

      assert fetch.calledTwice
      assert.equal _.keys(apiService.services).length, 0
      assert windowStub.setTimeout.calledThrice

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
      consolidateParams = sinon.stub apiService, 'consolidateParams', (params) ->
        consolidatedParams[params.length - 1]

      channelForParams = sinon.stub apiService, 'channelForParams', -> channelName
      fetch = sinon.stub apiService, 'fetch'
      shouldFetchOnParamsUpdate = sinon.stub apiService, 'shouldFetchOnParamsUpdate'

      apiService.addSubscription
        pollingInterval: pollingInterval
        params: params1

      callback = windowStub.setTimeout.lastCall.args[0]
      callback()

      apiService.addSubscription
        pollingInterval: pollingInterval
        params: params2

      assert shouldFetchOnParamsUpdate.calledOnce

      args = apiService.shouldFetchOnParamsUpdate.lastCall.args
      assert.ok _.isEqual(args[0], consolidatedParams[1])
      assert.ok _.isEqual(args[1], consolidatedParams[0])
      assert.equal args[2], channelName

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
      consolidateParams = sinon.stub apiService, 'consolidateParams', (params) ->
        consolidatedParams[params.length - 1]

      channelForParams = sinon.stub apiService, 'channelForParams', -> channelName
      fetch = sinon.stub apiService, 'fetch'
      shouldFetchOnParamsUpdate = sinon.stub apiService, 'shouldFetchOnParamsUpdate', -> true

      apiService.addSubscription
        pollingInterval: pollingInterval
        params: params1

      callback = windowStub.setTimeout.lastCall.args[0]
      callback()

      apiService.addSubscription
        pollingInterval: pollingInterval
        params: params2

      timeout = windowStub.setTimeout.lastCall.args[1]
      assert.equal timeout, 0

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
      consolidateParams = sinon.stub apiService, 'consolidateParams', (params) ->
        consolidatedParams[params.length - 1]

      channelForParams = sinon.stub apiService, 'channelForParams', -> channelName
      fetch = sinon.stub apiService, 'fetch'
      shouldFetchOnParamsUpdate = sinon.stub apiService, 'shouldFetchOnParamsUpdate', -> false

      apiService.addSubscription
        pollingInterval: pollingInterval
        params: params1


      callback = windowStub.setTimeout.lastCall.args[0]
      callback()

      apiService.addSubscription
        pollingInterval: pollingInterval
        params: params2

      timeout = windowStub.setTimeout.lastCall.args[1]
      assert.equal timeout, 100

    it 'does not ask to fetch immediately if params did not change', ->
      params1 = {}
      params2 = {}
      pollingInterval = 100
      channelName = 'test'

      consolidatedParams = sinon.stub apiService, 'consolidateParams', (params) -> {}
      channelForParams = sinon.stub apiService, 'channelForParams', -> channelName
      fetch = sinon.stub apiService, 'fetch'
      shouldFetchOnParamsUpdate = sinon.stub apiService, 'shouldFetchOnParamsUpdate', -> false

      apiService.addSubscription
        pollingInterval: pollingInterval
        params: params1


      callback = windowStub.setTimeout.lastCall.args[0]
      callback()

      apiService.addSubscription
        pollingInterval: pollingInterval
        params: params2

      assert.equal shouldFetchOnParamsUpdate.callCount, 0

    it 'does not ask to fetch immediately if params change on different channels', ->

      params1 = {}
      params2 = {}
      pollingInterval = 100
      channelName = 'test'

      consolidateParams = sinon.stub apiService, 'consolidateParams', (params) ->
        switch params[0]
          when params1 then { foo: 'bar' }
          when params2 then { baz: 'qux' }
          else {}

      channelForParams = sinon.stub apiService, 'channelForParams', (params) ->
        switch params
          when params1 then '1'
          when params2 then '2'
          else ''

      fetch = sinon.stub apiService, 'fetch'
      shouldFetchOnParamsUpdate = sinon.stub apiService, 'shouldFetchOnParamsUpdate', -> false

      apiService.addSubscription
        pollingInterval: pollingInterval
        params: params1

      callback = windowStub.setTimeout.lastCall.args[0]
      callback()

      apiService.addSubscription
        pollingInterval: pollingInterval
        params: params2

        assert.equal shouldFetchOnParamsUpdate.callCount, 0

    it 'updates the polling interval to the most frequent rate', ->

      params1 = {}
      params2 = {}
      pollingInterval1 = 100
      pollingInterval2 = 50

      consolidateParams = sinon.stub apiService, 'consolidateParams', -> params1
      channelForParams = sinon.stub apiService, 'channelForParams', -> 'test'
      fetch = sinon.stub apiService, 'fetch'
      shouldFetchOnParamsUpdate = sinon.stub apiService, 'shouldFetchOnParamsUpdate', -> true

      apiService.addSubscription
        pollingInterval: pollingInterval1
        params: params1

      callback = windowStub.setTimeout.lastCall.args[0]
      callback()

      # the timeout for the first callback is always 0. Repetition sidesteps that case
      callback = windowStub.setTimeout.lastCall.args[0]
      callback()

      apiService.addSubscription
        pollingInterval: pollingInterval2
        params: params2

      timeout = windowStub.setTimeout.lastCall.args[1]
      assert.equal timeout, 50

    it 'does not update the polling interval if the new value is less frequent', ->

      params1 = {}
      params2 = {}
      pollingInterval1 = 50
      pollingInterval2 = 100

      consolidateParams = sinon.stub apiService, 'consolidateParams', -> params1
      channelForParams = sinon.stub apiService, 'channelForParams', -> 'test'
      fetch = sinon.stub apiService, 'fetch'
      shouldFetchOnParamsUpdate = sinon.stub apiService, 'shouldFetchOnParamsUpdate', -> true

      apiService.addSubscription
        pollingInterval: pollingInterval1
        params: params1

      callback = windowStub.setTimeout.lastCall.args[0]
      callback()

      # the timeout for the first callback is always 0. Repetition sidesteps that case
      callback = windowStub.setTimeout.lastCall.args[0]
      callback()

      timeout = windowStub.setTimeout.lastCall.args[1]
      assert.equal timeout, 50

      apiService.addSubscription
        pollingInterval: pollingInterval2
        params: params2

      timeout = windowStub.setTimeout.lastCall.args[1]
      assert.equal timeout, 50

    it 'passes the correct remaining timeout when the polling interval changes', ->

      params1 = {}
      params2 = {}
      pollingInterval1 = 100
      pollingInterval2 = 50

      elapsedTime = 20
      remainingTime = pollingInterval2 - elapsedTime

      consolidateParams = sinon.stub apiService, 'consolidateParams', -> params1
      channelForParams = sinon.stub apiService, 'channelForParams', -> 'test'
      fetch = sinon.stub apiService, 'fetch'
      shouldFetchOnParamsUpdate = sinon.stub apiService, 'shouldFetchOnParamsUpdate', -> true

      apiService.addSubscription
        pollingInterval: pollingInterval1
        params: params1

      callback = windowStub.setTimeout.lastCall.args[0]
      callback()

      # the timeout for the first callback is always 0. Repetition sidesteps that case
      callback = windowStub.setTimeout.lastCall.args[0]
      callback()

      windowStub.Date.setNow 20

      apiService.addSubscription
        pollingInterval: pollingInterval2
        params: params2

      timeout = windowStub.setTimeout.lastCall.args[1]
      assert.equal timeout, remainingTime

    it 'passes the correct remaining timeout when interval does not update', ->

      params1 = {}
      params2 = {}
      pollingInterval = 100

      remainingTime = pollingInterval

      consolidateParams = sinon.stub apiService, 'consolidateParams', (params) ->
        switch params[0]
          when params1 then { foo: 'bar' }
          when params2 then { baz: 'qux' }
          else {}

      channelForParams = sinon.stub apiService, 'channelForParams', -> 'test'
      fetch = sinon.stub apiService, 'fetch'
      shouldFetchOnParamsUpdate = sinon.stub apiService, 'shouldFetchOnParamsUpdate', -> true

      apiService.addSubscription
        pollingInterval: pollingInterval
        params: params1

      callback = windowStub.setTimeout.lastCall.args[0]
      callback()

      # the timeout for the first callback is always 0. Repetition sidesteps that case
      callback = windowStub.setTimeout.lastCall.args[0]
      callback()

      windowStub.Date.setNow 20

      apiService.addSubscription
        pollingInterval: pollingInterval
        params: params2

      timeout = windowStub.setTimeout.lastCall.args[1]
      assert.equal timeout, remainingTime

  describe 'fetches data', ->
    describe 'default model', ->
      it 'syncs', ->
        model = new apiService.Model()
        sync = sinon.stub apiService, 'sync'

        method = 'GET'
        model = model
        options = {}

        model.sync method, model, options

        assert.equal sync.callCount, 1
        args = sync.lastCall.args
        assert.equal args.length, 3
        assert.equal args[0], method
        assert.equal args[1], model
        assert.equal args[2], options
        assert.equal sync.lastCall.thisValue, apiService

      it 'gets the URL', ->
        model = new apiService.Model()
        url = sinon.stub apiService, 'url'

        model.url()

        assert url.calledOnce
        args = url.lastCall.args
        assert.equal args.length, 1
        assert.equal args[0], model
        assert.equal url.lastCall.thisValue, apiService

      it 'parses the response', ->
        model = new apiService.Model()
        parse = sinon.stub apiService, 'parse'

        response = {}
        options = {}
        model.parse response, options

        assert parse.calledOnce
        args = parse.lastCall.args
        assert.equal args.length, 3
        assert.equal args[0], response
        assert.equal args[1], options
        assert.equal args[2], model
        assert.equal parse.lastCall.thisValue, apiService

      it 'can be overridden by getModelInstance', ->
        model = new Backbone.Model
        model.fetch = sinon.spy()

        apiService.getModelInstance = -> model

        consolidatedParams = {}

        apiService.onFetchSuccess = ->
        apiService.onFetchError = ->

        callbacks =
          success: apiService.onFetchSuccess
          error: apiService.onFetchError

        apiService.fetch consolidatedParams

        assert model.fetch.calledOnce

        args = model.fetch.lastCall.args
        assert.ok _.isEqual(args[0], callbacks)

    it 'calls fetch on the service', ->

      consolidatedParams = {}

      consolidateParams = sinon.stub apiService, 'consolidateParams', -> consolidatedParams
      fetch = sinon.stub apiService, 'fetch'

      apiService.addSubscription {}

      callback = windowStub.setTimeout.lastCall.args[0]
      callback()

      assert fetch.calledOnce

      args = fetch.lastCall.args
      assert.equal args[0], consolidatedParams

    it 'calls fetch on the model', ->

      consolidatedParams = {}

      modelFetch = sinon.spy()

      getModelInstance = sinon.stub apiService, 'getModelInstance', (params) ->
        assert.equal params, consolidatedParams
        model = new Backbone.Model params
        model.fetch = modelFetch
        model

      apiService.onFetchSuccess = ->
      apiService.onFetchError = ->

      callbacks =
        success: apiService.onFetchSuccess
        error: apiService.onFetchError

      apiService.fetch consolidatedParams

      assert modelFetch.calledOnce
      args = modelFetch.lastCall.args
      assert.ok _.isEqual(args[0], callbacks)
