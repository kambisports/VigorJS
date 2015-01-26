gulp = require 'gulp'

gulp.task 'default', ['clean'], ->
  # Run build tasks
  gulp.start 'coffee',
             'server',
             'watch'

