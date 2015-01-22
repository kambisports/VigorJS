fs = require 'fs'
onlyScripts = require './utils/script-filter'
tasks = fs.readdirSync('./gulp/tasks/').filter(onlyScripts)


tasks.forEach (task) ->
  require "./tasks/#{task}"
