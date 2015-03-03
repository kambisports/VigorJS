define (require) ->

	_ = require 'lib/underscore'
	PackageBase = require 'common/PackageBase'
	ListView = require './ListView'

	###
		This ui component does not have its own Producer, so
		it must be populated with data from parent component.
	###
	class GenericListView extends PackageBase

		# private properties
		_listView: undefined

		#----------------------------------------------
		# Public methods
		#----------------------------------------------
		constructor: (group) ->
			super

			@_listView = new ListView()
			@$el = @_listView.$el

		render: ->
			@_listView.render()
			_.defer =>
				do @renderDeferred.resolve
			return @


		dispose: ->
			do @_listView?.dispose
			@_listView = undefined

		NAME: 'GenericListView'

	return GenericListView
