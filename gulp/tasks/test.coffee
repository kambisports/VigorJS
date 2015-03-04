gulp = require 'gulp'
istanbul = require 'gulp-coffee-istanbul'
mocha = require 'gulp-mocha'
tap = require 'gulp-tap'
# nodeSetup = require '../../test/spec/setup/node'

coffeeFiles = ['src/**/*.coffee']
distFile = ['dist/backbone.vigor.js']
specFiles = ['test/**/*.coffee']

gulp.task 'test', ->
  gulp.src distFile
    .pipe istanbul({includeUntested: true}) # Covering files
    # .pipe tap (f) ->
      # Make sure all files are loaded to get accurate coverage data
      # p = require f.path
    .pipe istanbul.hookRequire()
    .on 'finish', ->
      gulp.src specFiles
        .pipe mocha reporter: 'spec'
        .pipe istanbul.writeReports() # Creating the reports after tests run

gulp.task 'test-no-coverage', ->
  gulp.src specFiles
    .pipe mocha reporter: 'spec'
