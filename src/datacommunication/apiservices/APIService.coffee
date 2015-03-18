do ->
  # the ServiceChannel class is private to Service
  # A service channel does not perform fetches itself, but asks the service to fetch with the
  # consolidated params
  class ServiceChannel

    subscribers: undefined
    pollingInterval: undefined
    lastPollTime: undefined
    timeout: undefined
    name: undefined


    constructor: (@_window, @name, @service, @subscribers) ->
      @params = @getParams()
      @restart()


    # restart the channel. This takes into account the time elapsed
    # since the last poll as well as the poll interval
    restart: ->
      @pollingInterval = @getPollingInterval()

      if @lastPollTime?
        elapsedWait = @_window.Date.now() - @lastPollTime
        wait = @pollingInterval - elapsedWait

        if wait < 0
          wait = 0
      else wait = 0

      @setupNextFetch wait

    # stopping the channel cleans up and asks the service to remove it
    stop: ->
      @_window.clearTimeout @timeout
      @timeout = undefined
      @subscribers = undefined
      @params = undefined
      @service.removeChannel @

    # sets up a timeout to execute the next fetch
    # optionally given a wait value to override the polling interval, for example
    # when restarting after changing the polling interval
    setupNextFetch: (wait = @pollingInterval) ->

      @_window.clearTimeout @timeout
      @timeout = @_window.setTimeout (_.bind ->
        @lastPollTime = @_window.Date.now()
        @service.fetch @params

        # if there are any requests with a zero polling interval, we can
        # and should remove them
        @cullImmediateRequests()

        # check to make sure we still have subscribers after culling
        # immediate requests
        if @subscribers?

          if @pollingInterval > 0
            @setupNextFetch()
          else
            @timeout = undefined
      , @), wait


    addSubscription: (subscriber) ->
      unless _.contains @subscribers, subscriber
        @subscribers.push subscriber

        @onSubscriptionsChanged()


    removeSubscription: (subscriber) ->
      if _.contains @subscribers, subscriber
        @subscribers = _.without @subscribers, subscriber

        if @subscribers.length is 0
          @stop()
        else
          @onSubscriptionsChanged()


    onSubscriptionsChanged: ->
      params = @getParams()
      didParamsChange = not _.isEqual params, @params

      oldParams = @params
      @params = params

      shouldFetchImmediately = false

      if didParamsChange
        shouldFetchImmediately = @service.shouldFetchOnParamsUpdate @params, oldParams, @name

      if shouldFetchImmediately
        @lastPollTime = undefined
        @restart()

      else if @getPollingInterval() isnt @pollingInterval
        @restart()


    # returns the lowest polling interval of subscribers
    # if no subscriber has a polling interval, we return 0 which represents
    # an immediate request on add
    getPollingInterval: ->

      pollingInterval = _.min _.map @subscribers, (subscriber) ->
        subscriber.pollingInterval

      if pollingInterval is Infinity then 0 else pollingInterval

    # a channel always holds an up-to-date copy of the consilidated params
    # this method updates those params, and is called whenever a subscriber is
    # added or removed
    getParams: ->
      @service.consolidateParams (_.filter _.map @subscribers, (subscriber) ->
        subscriber.params
      ), @name


    # remove all subscribers with no polling interval
    cullImmediateRequests: ->
      immediateRequests = _.filter @subscribers, (subscriber) ->
        (subscriber.pollingInterval is undefined) or (subscriber.pollingInterval is 0)

      # remove the immediate requests. this will never trigger a
      # restart because the polling interval is zero and cannot be lowered
      _.each immediateRequests, (immediateRequest) ->
        @removeSubscription immediateRequest
      , @

      @pollingInterval = @getPollingInterval()


  class APIService

    # optionally pass in a window object to stub Date, set/clearTimeout for testing
    constructor: (@_window = window) ->
      @channels = {}

      service = @

      # sync is called with the model as context
      # url and parse are called with the service as the context
      # url is passed the model
      # parse is passed the sync response and options but not the model
      @Model = Backbone.Model.extend
        sync: (method, model, options) ->
          service.sync method, model, options

        url: ->
          service.url @

        parse: (resp, options) ->
          service.parse resp, options, @

    # overridable
    # convert an array of params for the subscribers on this channel into
    # a single params object
    # the default implementation just returns the first params in the array
    # this is fine when using the default implementation of channelForParams
    # because all the params are identical anyway
    consolidateParams: (paramsArray, channelName) ->
      paramsArray[0]


    # overridable
    # return the name of the channel that should request data for the given params
    # by default, subscribers with identical params are put on the same channel
    channelForParams: (params) ->
      # null/undefined should be equivalent to an empty params object
      (JSON.stringify params) or "{}"


    # overridable
    # return true if the service should fetch immediately after the given params update
    shouldFetchOnParamsUpdate: (newParams, oldParams, channelName) ->
      true


    # overridable fetch/post success/error callbacks
    onFetchSuccess: ->
    onFetchError: ->
    onPostSuccess: ->
    onPostError: ->


    # overridable model sync method
    sync: (method, model, options) ->
      Backbone.Model.prototype.sync.call model, method, model, options

    # overridable model url method
    url: (model) ->
      Backbone.Model.prototype.url.call model

    # overridable model parse method
    parse: (resp, options, model) ->
      Backbone.Model.prototype.parse.call model


    # an object referencing the channels owned by this service
    channels: undefined


    removeChannel: (channel) ->
      @channels = _.without @channels, channel


    addSubscription: (subscriber) ->
      method = subscriber.method or 'GET'
      switch method
        when 'GET'
          @addGetSubscription subscriber
        when 'POST'
          @post subscriber.postParams
        when 'PUT'
          throw 'PUT not yet implemented'
        when 'DELETE'
          throw 'DELETE not yet implemented'


    addGetSubscription: (subscriber) ->
      channelName = @channelForParams subscriber.params
      channel = @channels[channelName]

      if channel?
        channel.addSubscription subscriber

      else
        @channels[channelName] = new ServiceChannel @_window, channelName, @, [subscriber]

    removeSubscription: (subscriber) ->
      if subscriber?
        channelId = @channelForParams subscriber.params
        channel = @channels[channelId]

        if channel?
          channel.removeSubscription subscriber


    getModelInstance: (params) ->
      new @Model params


    propagateResponse: (key, responseData) ->
      @trigger key, responseData


    fetch: (params) ->
      model = @getModelInstance params
      model.fetch
        success: @onFetchSuccess
        error: @onFetchError


    post: (params) ->
      model = @getModelInstance params
      model.save undefined,
        success: @onPostSuccess
        error: @onPostError

  _.extend APIService.prototype, Backbone.Events
  APIService.extend = Vigor.extend
  Vigor.APIService = APIService

