do ->
  # ## ServiceChannel
  # The ServiceChannel class is private to the APIService class. Service channels are used to group subscriptions to an
  # API service into sets of subscriptions whose requirements can be fulfilled with a single request, thus reducing
  # network usage.<br/>
  # Each subscription to the channel may have a polling interval, and the channel will ask the service that created
  # it to perform a fetch when the polling intervals elapse.<br/>
  # Service channels are not used for post requests, which cannot be consolidated.
  class ServiceChannel

    # An array of subscription objects, each of which may contain a pollingInterval in ms, and a params object
    subscribers: undefined

    # The minimum polling interval of the subscribers, or 0
    pollingInterval: undefined

    # The unix timestamp of the last poll
    lastPollTime: undefined

    # A timeout id, as returned by window.setTimeout, for the next poll.
    timeout: undefined

    # The name of this channel; used by the API service to uniquely identify it.
    name: undefined

    # **constructor**<br/>
    # If subscribers are provided, the requests will start immediately.
    constructor: (@_window, @name, @service, @subscribers) ->
      @params = @getParams()
      @restart()


    # **restart**<br/>
    # Restarts the channel, causing it to schedule the next request.<br/>
    # This method can be called at any time, since it takes into account the time since the last request.
    restart: ->
      @pollingInterval = @getPollingInterval()

      if @lastPollTime?
        elapsedWait = @_window.Date.now() - @lastPollTime
        wait = Math.max @pollingInterval - elapsedWait, 0
      else
        wait = 0

      @setupNextFetch wait

    # **stop**<br/>
    # Stops the channel and asks the service to remove it.
    stop: ->
      @_window.clearTimeout @timeout
      @timeout = undefined
      @subscribers = undefined
      @params = undefined
      @service.removeChannel @

    # **setupNextFetch**<br/>
    # @param [wait]: number<br/>
    # The amount of time to wait until the fetch. Defaults to the current polling interval.
    #
    # Schedules the next fetch to start the given number of ms in the future.
    setupNextFetch: (wait = @pollingInterval) ->

      @_window.clearTimeout @timeout

      @timeout = @_window.setTimeout (_.bind ->
        @lastPollTime = @_window.Date.now()
        @service.fetch @params

        # remove requests with a zero polling interval since the request has now been made
        @cullImmediateRequests()

        # check to make sure we still have subscribers after culling
        # immediate requests
        if @subscribers?
          # if we still have subscribers, set up the next fetch
          if @pollingInterval > 0
            @setupNextFetch()
          else
            @timeout = undefined
      , @), wait


    # **addSubscription**<br/>
    # @param [subscriber]: Object<br/>
    # The subscription to add. May contain a pollingInterval in ms, and a params object.
    #
    # Add a subscription to the channel, causing the params to update. A fetch may be scheduled or rescheduled.
    addSubscription: (subscriber) ->
      unless _.contains @subscribers, subscriber
        @subscribers.push subscriber

        @onSubscriptionsChanged()


    # **removeSubscription**<br/>
    # @param [subscriber]: Object<br/>
    # The subscription to remove. This must be the same reference as the object used when subscribing (i.e. ===).
    #
    # Remove a subscription to the channel, causing the params to update. The next fetch may be rescheduled or the
    # channel may be stopped if this is the last subscriber.
    removeSubscription: (subscriber) ->
      if _.contains @subscribers, subscriber
        @subscribers = _.without @subscribers, subscriber

        if @subscribers.length is 0
          @stop()
        else
          @onSubscriptionsChanged()

    # **onSubscriptionsChanged**<br/>
    # Updates the params and reschedules the next fetch if necessary.
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


    # **getPollingInterval**<br/>
    # @returns [pollingInterval]: number<br/>
    # The current polling interval in ms.
    #
    # Returns the lowest polling interval of subscribers. If no subscriber has a polling interval,
    # returns 0 which represents an immediate request.
    getPollingInterval: ->

      pollingInterval = _.min _.map @subscribers, (subscriber) ->
        subscriber.pollingInterval

      if pollingInterval is Infinity then 0 else pollingInterval


    # **getParams**<br/>
    # @returns [params]: Object<br/>
    # The current consolidated params for this channel.
    #
    # A channel always holds an up-to-date copy of the consilidated params.
    # This method updates those params, and is called whenever a subscriber is
    # added or removed.
    getParams: ->
      @service.consolidateParams (_.filter _.map @subscribers, (subscriber) ->
        subscriber.params
      ), @name


    # **cullImmediateRequests**<br/>
    # Removes all subscribers without a polling interval.
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

