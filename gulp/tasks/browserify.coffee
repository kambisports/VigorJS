gulp = require 'gulp'
browserify = require 'browserify'
watchify = require 'watchify'
minifyify = require 'minifyify'
source = require 'vinyl-source-stream'
gulpif = require 'gulp-if'
streamify = require 'gulp-streamify'
uglify = require 'gulp-uglify'
livereload = require "gulp-livereload"
config = require '../config'


appBundler = (externals) ->
  options =
    entries: ["#{config.source}#{config.bootstrap}"]
    extensions: ['.coffee']
    fullPaths: false
    packageCache: {}
    cache: {}
    debug: config.debug

  bundler = browserify options

  if global.isWatching
    bundler = watchify bundler

  externals.forEach (external) ->
    if external.expose?
      bundler.external external.require, expose: external.expose
    else
      bundler.external external.require

  return bundler


bundle = (bundler, outputName, dest) ->
  doUglify = config.debug
  outputName = "#{outputName}.js"
  if doUglify then outputName = "#{outputName}.min.js"

  console.log outputName
  stream = bundler
    .bundle()
    .pipe(source(outputName))
    .pipe(gulpif(doUglify, streamify(uglify())))
    .pipe(gulp.dest(dest))
    .pipe(livereload())

  return stream
    .on('error', (error) -> console.log 'error: ', error)
    .on('end', -> console.log 'Finished')


bundleAndWatch = (bundler, outputName, dest) ->
  if global.isWatching
    bundler.on 'update', ->
      bundle(bundler, outputName, dest)

  return bundle(bundler, outputName, dest)

gulp.task 'build', ->
  bundler = appBundler(config.externals)
  outputName = config.outputName
  dest = config.distTarget
  return bundleAndWatch bundler, outputName, dest
