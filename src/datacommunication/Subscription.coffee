class Subscription

  id: undefined
  callback: undefined
  options: undefined

  constructor: (@id, @callback, @options) ->

### start-test-block ###
# this will be removed in distribution build
Vigor.Subscription = Subscription
### end-test-block ###
