define (require) ->

	_ = require 'lib/underscore'
	PackageBase = require 'common/PackageBase'
	HelloWorldView = require './HelloWorldView'
	HelloWorldViewModel = require './HelloWorldViewModel'

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

			@_helloWorldModel = new HelloWorldViewModel()
			@_helloWorldView = new HelloWorldView
				viewModel: @_helloWorldModel

		render: ->
			@$el = @_helloWorldView.render().$el

			_.defer =>
				do @renderDeferred.reject

			return @

		dispose: ->
			do @_helloWorldView.dispose
			do @_helloWorldModel.dispose
			@_helloWorldView = undefined
			@_helloWorldModel = undefined

		NAME: 'HelloWorld'

	return HelloWorld
