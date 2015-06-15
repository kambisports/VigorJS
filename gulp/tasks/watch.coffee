gulp = require 'gulp'
livereload = require 'gulp-livereload'
config = require '../config'

gulp.task 'watch', ['server'], ->
  livereload.listen({ basePath: config.dest});
  gulp.watch ["#{config.src}/**/*.coffee"], ['build-coffee']
  gulp.watch ["./examples/**/*.html"], ['reload']
