define (require) ->

	_ = require 'lib/underscore'
	PackageBase = require 'common/PackageBase'
	HelloWorldView = require './HelloWorldView'
	HelloWorldModel = require './HelloWorldModel'

	class HelloWorld extends PackageBase

		$el: undefined
		# private properties
		_helloWorldModel: undefined
		_helloWorldView: undefined

		#----------------------------------------------
		# Public methods
		#----------------------------------------------
		constructor: ->
			super

			@_helloWorldModel = new HelloWorldModel()
			@_helloWorldView = new HelloWorldView
				viewModel: @_helloWorldModel


		render: ->
			@$el = @_helloWorldView.render().$el
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
