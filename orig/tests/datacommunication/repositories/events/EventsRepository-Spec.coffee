define (require) ->

	EventsRepository = require 'datacommunication/repositories/events/EventsRepository'

	describe 'EventsRepository', ->

		repository = undefined

		describe 'EventsRepository', ->

			beforeEach ->
				# Create a new instance (EventRepo is a singleton)
				repository = new EventsRepository.constructor()
				repository.reset()


			it 'should return events that are live from getLiveEvents call', ->
				repository.set [
					{id: 111, state: 'NOT_STARTED'}
					{id: 222, state: 'NOT_STARTED'}
					{id: 333, state: 'NOT_STARTED'}
				], {silent: true}

				liveEvents = do repository.getLiveEvents
				expect(liveEvents.length).toBe 0

				repository.set [
					{id: 111, state: 'STARTED'}
					{id: 222, state: 'NOT_STARTED'}
					{id: 333, state: 'STARTED'}
				], {silent: true}


				liveEvents = do repository.getLiveEvents
				expect(liveEvents.length).toBe 2
				expect(liveEvents[0].id).toBe 111
				expect(liveEvents[1].id).toBe 333

			it 'should return most popular events from getMostPopularEvents call', ->
				repository.set [
					{id: 111, state: 'NOT_STARTED'}
					{id: 222, state: 'NOT_STARTED'}
					{id: 333, state: 'NOT_STARTED'}
				], {silent: true}

				mostPopularEvents = do repository.getMostPopularEvents
				expect(mostPopularEvents.length).toBe 0

				# simulation of parse of most popular models
				repository.mostPopularEvents = [{id: 111, state: 'NOT_STARTED'}]

				mostPopularEvents = do repository.getMostPopularEvents
				expect(mostPopularEvents.length).toBe 1
				expect(mostPopularEvents[0].id).toBe 111