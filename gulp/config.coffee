config =
  bootstrap: './src/bootstrap.coffee'
  outputName: 'backbone.vigor.js'
  serverTarget: './examples'
  dest: './dist'
  src: './src/'
  istanbulEntryPoint: ['./dist/backbone.vigor.js']
  specFiles: ['./test/spec/**/*.coffee']
  fileTypes: ['.js', '.css', '.txt', '.ico', '.html', '.png']
  debug: false

module.exports = config