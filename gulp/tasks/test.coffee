gulp = require 'gulp'
config  = require '../config'
istanbul = require 'gulp-coffee-istanbul'
mocha = require 'gulp-mocha'

global.extend = (obj, mixin) ->
  obj[name] = method for name, method of mixin
  obj

gulp.task 'test', ->
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
