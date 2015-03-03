define (require) ->

	Backbone = require 'lib/backbone'

	class Repository extends Backbone.Collection

		_debouncedAddedModels: undefined
		_debouncedChangedModels: undefined
		_debouncedRemovedModels: undefined
		_eventTimeout: undefined

		initialize: ->
			@_debouncedAddedModels = {}
			@_debouncedChangedModels = {}
			@_debouncedRemovedModels = {}

			do @addDebouncedListeners
			super

		addDebouncedListeners: ->
			@on 'all', @_onAll

		getByIds: (ids) ->
			models = []
			for id in ids
				models.push @get id
			return models

		isEmpty: ->
			return @models.length <= 0

		_onAll: (event, args...) ->
			switch event
				when 'add' then @_onAdd.apply(@, args)
				when 'change' then @_onChange.apply(@, args)
				when 'remove' then @_onRemove.apply(@, args)

			clearTimeout @_eventTimeout
			@_eventTimeout = setTimeout @_debounced, 100

		_onAdd: (model) =>
			@_debouncedAddedModels[model.id] = model

		_onChange: (model) =>
			@_debouncedChangedModels[model.id] = model

		_onRemove: (model) =>
			@_debouncedRemovedModels[model.id] = model

		_debouncedAdd: ->
			event = Repository::REPOSITORY_ADD
			models = _.values @_debouncedAddedModels
			@_debouncedAddedModels = {}
			if models.length > 0
				@trigger event, models, event
			return models

		_debouncedChange: ->
			event = Repository::REPOSITORY_CHANGE
			models = _.values @_debouncedChangedModels
			@_debouncedChangedModels = {}
			if models.length > 0
				@trigger event, models, event
			return models

		_debouncedRemove: ->
			event = Repository::REPOSITORY_REMOVE
			models = _.values @_debouncedRemovedModels
			@_debouncedRemovedModels = {}
			if models.length > 0
				@trigger event, models, event
			return models

		_debouncedDiff: (added, changed, removed) ->
			event = Repository::REPOSITORY_DIFF
			if 	added.length or \
					changed.length or \
					removed.length

				added = _.difference(added, removed)
				consolidated = _.uniq added.concat(changed)

				models =
					added: added
					changed: changed
					removed: removed
					consolidated: consolidated

				@trigger event, models, event

		_debounced: =>
			@_debouncedDiff @_debouncedAdd(), @_debouncedChange(), @_debouncedRemove()

		REPOSITORY_DIFF: 'repository_diff'
		REPOSITORY_ADD: 'repository_add'
		REPOSITORY_CHANGE: 'repository_change'
		REPOSITORY_REMOVE: 'repository_remove'

	return Repository