gulp = require 'gulp'
coffee = require 'gulp-coffee'
include = require 'gulp-include'
rename = require 'gulp-rename'
livereload = require 'gulp-livereload'
config = require '../config'

gulp.task 'coffee', ->
  gulp.src(config.bootstrap)
    .pipe include()
    .pipe coffee()
    .pipe rename(config.outputName)
    .pipe gulp.dest(config.dest)
    .pipe livereload()
