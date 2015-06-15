gulp = require 'gulp'

gulp.task 'default', ['clean'], ->
  # Run build tasks
  gulp.start 'build-coffee',
             'server',
             'watch'

