gulp = require 'gulp'
rimraf = require "gulp-rimraf"
config = require '../config'

gulp.task 'clean', ->
  gulp.src(config.dest, read: false)
    .pipe rimraf()

