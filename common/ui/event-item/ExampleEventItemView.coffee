define (require) ->

	BaseEventItemView = require './BaseEventItemView'
	tmpl = require 'hbs!./templates/EventItem'

	class ExampleEventItemView extends BaseEventItemView



	return ExampleEventItemView