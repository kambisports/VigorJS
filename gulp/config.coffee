config =
  bootstrap: 'bootstrap.coffee'
  outputName: 'backbone.whateverwewanttocallit'
  distTarget: './dist'
  serverTarget: './examples'
  source: './src/'
  fileTypes: ['.js', '.css', '.txt', '.ico', '.html', '.png']
  debug: false
  externals: [
    {require: 'jquery', expose: 'jquery'}
    {require: 'backbone', expose: 'backbone'}
    {require: 'underscore', expose: '_'}
  ]

module.exports = config