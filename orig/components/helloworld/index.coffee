define (require) ->

	$ = require 'jquery'
	_ = require 'lib/underscore'
	PackageBase = require 'common/PackageBase'
	HelloWorldView = require './HelloWorldView'
	HelloWorldViewModel = require './HelloWorldViewModel'

	class HelloWorld extends PackageBase

		$el: undefined
		# private properties
		_helloWorldModel: undefined
		_helloWorldView: undefined

		# private properties
		_helloWorldModel2: undefined
		_helloWorldView2: undefined

		#----------------------------------------------
		# Public methods
		#----------------------------------------------
		constructor: ->
			super

			@_helloWorldModel = new HelloWorldViewModel('dummy')
			@_helloWorldView = new HelloWorldView
				viewModel: @_helloWorldModel

			@_helloWorldModel2 = new HelloWorldViewModel('tummy')
			@_helloWorldView2 = new HelloWorldView
				viewModel: @_helloWorldModel2

		render: ->
			container = $ '<div></div>'
			# Bound to changes on its ID
			container.append @_helloWorldView.render().$el

			# Hello world that doesn't listen for indiviual changes
			#container.append @_helloWorldView2.render().$el
			@$el = container

			_.defer =>
				do @renderDeferred.resolve

			return @


		dispose: ->
			do @_helloWorldView.dispose
			do @_helloWorldModel.dispose
			@_helloWorldView = undefined
			@_helloWorldModel = undefined
			super

		HelloWorld.NAME = 'HelloWorld'

	return HelloWorld
