class ComponentIdentifier

	id: undefined
	callback: undefined
	options: undefined

	constructor: (componentId, componentCb, componentOptions) ->
		@id = componentId
		@callback = componentCb
		@options = componentOptions

Vigor.ComponentIdentifier = ComponentIdentifier