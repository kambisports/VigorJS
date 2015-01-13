define (require) ->

	Backbone = require 'lib/backbone'

	class GroupModel extends Backbone.Model

		defaults:
			level: 0
			parentId: undefined
			id: undefined
			sortOrder: undefined
			sport: undefined
			englishName: undefined
			name: undefined
			boCount: undefined
			eventCount: undefined
			secondsToNextEvent: undefined

	Object.defineProperty GroupModel.prototype, 'MODEL_TYPE',
		value: 'GroupModel'
		writeable: false
		configurable: false
		enumerable: true


	return GroupModel