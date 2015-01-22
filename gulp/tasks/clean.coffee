gulp = require 'gulp'
rimraf = require "gulp-rimraf"
config = require '../config'

gulp.task 'clean', ->
  gulp.src(config.distTarget, read: false)
    .pipe(rimraf())

