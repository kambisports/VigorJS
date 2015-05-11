gulp = require 'gulp'
config  = require '../config'
istanbul = require 'gulp-coffee-istanbul'
mocha = require 'gulp-mocha'
jsdom = require 'jsdom'

global.document = jsdom.jsdom()
global.window = document.defaultView

global.$ = require("jquery")
global._ = require 'underscore'
global.Backbone = require 'backbone'
global.Backbone.$ = global.$

global.extend = (obj, mixin) ->
  obj[name] = method for name, method of mixin
  obj

gulp.task 'test', ['coffee'], ->
  gulp.src config.istanbulEntryPoint
    .pipe istanbul({includeUntested: true}) # Covering files
    .pipe istanbul.hookRequire()
    .on 'finish', ->
      gulp.src config.specFiles
        .pipe mocha reporter: 'spec'
        .pipe istanbul.writeReports() # Creating the reports after tests run

gulp.task 'test-no-coverage', ->
  gulp.src specFiles
    .pipe mocha reporter: 'spec'
