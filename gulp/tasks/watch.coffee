config = require '../config'
gulp = require 'gulp'
livereload = require 'gulp-livereload'

gulp.task 'watch', ['server', 'coffee'], ->
  livereload.listen({ basePath: config.dest});
  gulp.watch ["#{config.src}/**/*.coffee"], ['coffee']
  gulp.watch ["./examples/**/*.html"], ['reload']
