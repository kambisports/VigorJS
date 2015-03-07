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

      args = spy.getCall(0).args

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
      args = spy.getCall(1).args

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

      sinon.stub apiService, 'consolidateParams', -> params
      fetch = sinon.stub apiService, 'fetch'

      apiService.addSubscription
        params: params

      assert windowStub.setTimeout.calledOnce
      args = windowStub.setTimeout.getCall(0).args

      assert.equal args.length, 2
      assert.equal args[1], 0
      callback = args[0]

      callback()

      assert fetch.calledOnce
      assert.equal _.keys(apiService.services).length, 0

    it 'does polled fetches', ->
      params = {}
      pollingInterval = 100

      sinon.stub apiService, 'consolidateParams', -> params
      fetch = sinon.stub apiService, 'fetch'

      apiService.addSubscription
        pollingInterval: pollingInterval
        params: params

      assert windowStub.setTimeout.calledOnce
      args = windowStub.setTimeout.getCall(0).args

      assert.equal args.length, 2
      assert.equal args[1], 0
      callback = args[0]

      callback()

      assert windowStub.setTimeout.calledTwice
      args = windowStub.setTimeout.getCall(1).args

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
      sinon.stub apiService, 'consolidateParams', (params) ->
        consolidatedParams[params.length - 1]

      channelForParams = sinon.stub apiService, 'channelForParams', -> channelName
      fetch = sinon.stub apiService, 'fetch'
      shouldFetchOnParamsUpdate = sinon.stub apiService, 'shouldFetchOnParamsUpdate'

      apiService.addSubscription
        pollingInterval: pollingInterval
        params: params1

      callback = windowStub.setTimeout.getCall(0).args[0]
      callback()

      apiService.addSubscription
        pollingInterval: pollingInterval
        params: params2

      assert shouldFetchOnParamsUpdate.calledOnce

      args = apiService.shouldFetchOnParamsUpdate.getCall(0).args
      assert.ok _.isEqual(args[0], consolidatedParams[1])
      assert.ok _.isEqual(args[1], consolidatedParams[0])
      assert.equal args[2], channelName

