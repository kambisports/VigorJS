gulp = require 'gulp'
shell = require 'gulp-shell'

gulp.task 'docco', shell.task [
	'find ./src/ -type f -name "*.coffee" | xargs docco'
]
