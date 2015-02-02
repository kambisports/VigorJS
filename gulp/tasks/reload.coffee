gulp = require 'gulp'
livereload = require 'gulp-livereload'

gulp.task 'reload', ->
  gulp.src('./examples/index.html')
    .pipe livereload()
