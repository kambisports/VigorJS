define (require) ->

	_ = require 'lib/underscore'
	Repository = require './Repository'

	class ServiceRepository extends Repository

		producersInterestedInUpdates: undefined

		_debouncedAddedModels: undefined
		_debouncedChangedModels: undefined
		_debouncedRemovedModels: undefined
		_eventTimeout: undefined

		initialize: ->
			@_debouncedAddedModels = {}
			@_debouncedChangedModels = {}
			@_debouncedRemovedModels = {}

			@producersInterestedInUpdates = []
			do @addDebouncedListeners
			super

		addDebouncedListeners: ->
			@on 'all', @_onAll

		isEmpty: ->
			return @models.length <= 0

		interestedInUpdates: (name) ->
			producerAlreadyInterested = _.indexOf(@producersInterestedInUpdates, name) > -1
			if producerAlreadyInterested
				return
			else
				@producersInterestedInUpdates.push name

			if @producersInterestedInUpdates.length > 0 then @trigger ServiceRepository::START_POLLING

		notInterestedInUpdates: (name) ->
			interestedProducerIndex = _.indexOf(@producersInterestedInUpdates, name)
			if interestedProducerIndex  > -1 then @producersInterestedInUpdates.splice interestedProducerIndex, 1

			if @producersInterestedInUpdates.length is 0 then @trigger ServiceRepository::STOP_POLLING

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
			event = ServiceRepository::REPOSITORY_ADD
			models = _.values @_debouncedAddedModels
			@_debouncedAddedModels = {}
			if models.length > 0
				@trigger event, models, event
			return models

		_debouncedChange: ->
			event = ServiceRepository::REPOSITORY_CHANGE
			models = _.values @_debouncedChangedModels
			@_debouncedChangedModels = {}
			if models.length > 0
				@trigger event, models, event
			return models

		_debouncedRemove: ->
			event = ServiceRepository::REPOSITORY_REMOVE
			models = _.values @_debouncedRemovedModels
			@_debouncedRemovedModels = {}
			if models.length > 0
				@trigger event, models, event
			return models

		_debouncedDiff: (added, changed, removed) ->
			event = ServiceRepository::REPOSITORY_DIFF
			if 	added.length or \
					changed.length or \
					removed.length

				models =
					added: _.difference added, removed
					changed: changed
					removed: removed

				@trigger event, models, event

		_debounced: =>
			@_debouncedDiff @_debouncedAdd(), @_debouncedChange(), @_debouncedRemove()

		POLL_ONCE: 'poll_once'
		START_POLLING: 'start_polling'
		STOP_POLLING: 'stop_polling'

		REPOSITORY_DIFF: 'repository_diff'
		REPOSITORY_ADD: 'repository_add'
		REPOSITORY_CHANGE: 'repository_change'
		REPOSITORY_REMOVE: 'repository_remove'

	return ServiceRepository