gulp = require 'gulp'
istanbul = require 'gulp-coffee-istanbul'
mocha = require 'gulp-mocha'

distFile = ['dist/backbone.vigor.js']
coffeeFiles = ['src/**/*.coffee']
specFiles = ['test/**/*.coffee']

gulp.task 'test', ->
  gulp.src distFile
    .pipe istanbul({includeUntested: true}) # Covering files
    .pipe istanbul.hookRequire()
    .on 'finish', ->
      gulp.src specFiles
        .pipe mocha reporter: 'spec'
        .pipe istanbul.writeReports() # Creating the reports after tests run

gulp.task 'test-no-coverage', ->
  gulp.src specFiles
    .pipe mocha reporter: 'spec'
