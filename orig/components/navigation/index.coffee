define (require) ->

	'use strict'

	PackageBase = require 'common/PackageBase'
	NavigationView = require './NavigationView'

	class Navigation extends PackageBase

		_navigationView: undefined

		constructor: (uglyWorkarounds) ->
			super
			@_navigationView = new NavigationView
				uglyWorkarounds: uglyWorkarounds


		render: ->
			return @_navigationView.render().$el

		NAME: 'Navigation'
