config =
  bootstrap: './src/bootstrap.coffee'
  outputName: 'vigor.js'
  outputMinifiedName: 'vigor.min.js'
  serverTarget: './examples'
  dest: './dist'
  src: './src/'
  istanbulEntryPoint: ['./dist/vigor.js']
  specFiles: ['./test/spec/**/*.coffee']
  fileTypes: ['.js', '.css', '.txt', '.ico', '.html', '.png']
  debug: false

module.exports = config