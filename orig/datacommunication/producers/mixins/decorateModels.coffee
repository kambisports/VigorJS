define (require) ->

	decorateModels: (models, decorateList) ->
		decoratedModels = []
		for model in models
			model = model.toJSON()
			decoratedModels.push @decorate(model, decorateList)
		return decoratedModels
