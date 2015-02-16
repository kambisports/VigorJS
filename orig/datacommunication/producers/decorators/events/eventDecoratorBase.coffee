define (require) ->

	eventDecoratorBase =

		addUrl: (eventJSON) ->
			eventJSON.url = "#event/#{eventJSON.id}"
			return eventJSON

	return eventDecoratorBase
