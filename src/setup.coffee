# Defaults
Vigor.settings =
  validateContract: false

setup = (configObj) ->
  settings = {}
  settings.validateContract = configObj.validateContract or false
  _.extend Vigor.settings, settings

Vigor.setup = setup