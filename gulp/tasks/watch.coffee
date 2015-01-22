config = require '../config'
gulp = require 'gulp'
livereload = require 'gulp-livereload'

gulp.task 'watch', ['setWatch', 'build'], ->
  livereload.listen({ basePath: config.distTarget });
  gulp.watch ["#{config.source}/**/*.coffee"], ['build']
