###
  Base class for services interacting with the API (polling)
  Each service is bound to a repository and whenever that repository has a listener
  for data, the service will start polling. If the repository has no active listeners the
  service will stop polling for data.
###

Poller = Backbone.Poller
ServiceRepository = Vigor.ServiceRepository

class ApiService

  service: undefined
  poller: undefined
  pollerOptions: undefined
  shouldStop: false
  url: undefined

  # Repository to listen for active listeners on, Default poll interval is 10 seconds
  constructor: (@repository, pollInterval = 10000) ->
    @service = new Backbone.Model()
    @service.url = @url
    @service.parse = @parse

    @pollerOptions = {
      delay: pollInterval
      delayed: false
      continueOnError: true
      autostart: false
    }

    @_createPoller @pollerOptions

  dispose: () ->
    do @_unbindPollerListeners

    @service = undefined
    @poller = undefined

  # This should be run from the class implementing this base
  parse: (response) =>
    @_validateResponse response isnt true
    if @shouldStop
      do @poller.stop

  run: ->
    throw 'ApiService->run must be overriden.'

  startPolling: =>
    do @poller?.start

  stopPolling: =>
    if @poller.active()
      @shouldStop = true
    else
      do @poller.stop

  propagateResponse: (key, responseData) ->
    @trigger key, responseData

  _createPoller: (options) ->
    @poller = Poller.get @service, options

    do @_unbindPollerListeners
    do @_bindPollerListeners

  _bindPollerListeners: () ->

    ###
    @poller.on 'success',  ->
      window.console.log 'Api service poller success'

    @poller.on 'complete', ->
      window.console.log 'Api service poller complete'
    ###

    @poller.on 'error', (e) ->
      window.console.log 'Api service poller error', arguments, @

  _unbindPollerListeners: () ->
    do @poller?.off

  # Check xhr status in some generic way here?
  # or use the backbone validate methdo in the models?
  _validateResponse: (response) ->
    removeThisLineOfCode = response
    return true

  _.extend @prototype, Backbone.Events

ApiService.extend = Vigor.extend
Vigor.ApiService = ApiService
