config  = require '../config'
gulp  = require 'gulp'
http = require "http"
nodeStatic = require "node-static"

isStaticResource = (url) ->
  return config.fileTypes.reduce (memo, fileType) ->
    return memo || url.indexOf(fileType) isnt -1
  , false

# Start server and redirect to index.html
gulp.task 'server', ->
  file = new nodeStatic.Server('./', cache: 0)
  port = process.env.PORT || 7070

  http.createServer((req, res) ->
    req.addListener('end', ->
      if !isStaticResource(req.url)
        req.url = "#{config.serverTarget}/index.html"

      file.serve req, res, (err, result) ->
        if err
          console.log 'Error serving %s - %s', req.url, err.message
          res.writeHead(err.status, err.headers)
          res.end()
      ).resume()
  ).listen(port)

  console.log('Development server running at http://localhost:%d', port)


