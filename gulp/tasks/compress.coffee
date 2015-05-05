gulp = require 'gulp'
coffee = require 'gulp-coffee'
include = require 'gulp-include'
rename = require 'gulp-rename'
uglify = require 'gulp-uglify'
config = require '../config'

gulp.task 'dist-minified', ->
  gulp.src(config.bootstrap)
    .pipe include()
    .pipe coffee()
    .on('error', handleError)
    .pipe uglify()
    .pipe rename(config.outputMinifiedName)
    .pipe gulp.dest(config.dest)

handleError = (error) ->
  console.log error
  this.emit 'end'
