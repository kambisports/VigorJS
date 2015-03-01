config  = require '../config'
gulp  = require 'gulp'
http = require "http"
nodeStatic = require "node-static"

# Start server and redirect to index.html
gulp.task 'server', ->
  file = new nodeStatic.Server('./', cache: 0)
  port = process.env.PORT || 7070

  http.createServer((req, res) ->
    req.addListener('end', ->
      file.serve req, res, (err, result) ->
        if err
          console.log 'Error serving %s - %s', req.url, err.message
          res.writeHead(err.status, err.headers)
          res.end()
      ).resume()
  ).listen(port)

  console.log('Development server running at http://localhost:%d', port)
