gulp = require 'gulp'
mocha = require 'gulp-mocha'
cover = require 'gulp-coverage'
nodeSetup = require '../..//test/spec/setup/node'

gulp.task 'test', ->
  gulp.src('./test/spec/**/*.coffee', { read: false })
    .pipe cover.instrument({
        pattern: ['**/test*']
        debugDirectory: 'debug'
    })
    .pipe mocha()
    .pipe cover.report(outFile: 'test/coverage.html')
