define (require) ->

	class EventDecoratorBase

		addUrl: (eventJSON) ->
			eventJSON.url = "#event/#{eventJSON.id}"
			return eventJSON

	return EventDecoratorBase
