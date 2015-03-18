define (require) ->

	DateUtil = require 'utils/DateUtil'
	Producer = require 'datacommunication/producers/Producer'
	SubscriptionKeys = require 'datacommunication/SubscriptionKeys'

	# Collections needed to build/produce data
	CouponsRepository = require 'datacommunication/repositories/coupons/CouponsRepository'
	CouponOutcomesRepository = require 'datacommunication/repositories/coupon-outcomes/CouponOutcomesRepository'
	OutcomesRepository = require 'datacommunication/repositories/outcomes/OutcomesRepository'
	BetoffersRepository = require 'datacommunication/repositories/betoffers/BetoffersRepository'
	EventsRepository = require 'datacommunication/repositories/events/EventsRepository'

	class BetFeedbackProducer extends Producer

		# the fetch subscription to the repository
		repoFetchSubscription: undefined
		outcomeOddsSubscription: undefined
		couponOutcomeIds: undefined

		constructor: ->
			super
			@couponOutcomeIds = []


		subscribeToRepositories: ->
			CouponsRepository.on CouponsRepository.REPOSITORY_DIFF, @_onDiffInRepository, @
			OutcomesRepository.on OutcomesRepository.REPOSITORY_DIFF, @_onDiffInRepository, @
			BetoffersRepository.on BetoffersRepository.REPOSITORY_DIFF, @_onDiffInRepository, @
			

		unsubscribeFromRepositories: ->
			CouponsRepository.off CouponsRepository.REPOSITORY_DIFF, @_onDiffInRepository, @
			OutcomesRepository.off OutcomesRepository.REPOSITORY_DIFF, @_onDiffInRepository, @
			BetoffersRepository.on BetoffersRepository.REPOSITORY_DIFF, @_onDiffInRepository, @
			CouponsRepository.removeSubscription CouponsRepository.ALL, @repoFetchSubscription
			OutcomesRepository.removeSubscription OutcomesRepository.OUTCOME_ODDS, @outcomeOddsSubscription


		subscribe: (options) ->
			@repoFetchSubscription =
				pollingInterval: 5000
				params:
					toDate: DateUtil.createBasicYMDString(-1)
					range_size: 50
					range_start: 0
					status: "SCF_PENDING"

			CouponsRepository.addSubscription CouponsRepository.ALL, @repoFetchSubscription
			do @_produceData
			do @_updateOucomeOddsSubscription

		_produceData: ->
			@produce SubscriptionKeys.BETFEEDBACK, @_buildData()

		_buildData: ->
			coupons = CouponsRepository.getCoupons()
			respond = []

			# Create objects to use for sorting the coupons
			for coupon in coupons
				hasLiveEvent = @_couponHasLiveEvent coupon
				respond.push {
					id: coupon.get('id')
					isAwaitingApproval: coupon.get('isAwaitingApproval')
					eligibleForCashIn: coupon.get('eligibleForCashIn')
					hasLiveEvent: hasLiveEvent
					hasCashInValue: @_couponHasCashInValue(coupon, hasLiveEvent)
				}

			# Sort coupons
			respond.sort (a, b) ->
				switch
					when a.isAwaitingApproval isnt b.isAwaitingApproval
						if a.isAwaitingApproval then -1 else 1

					when a.hasCashInValue isnt b.hasCashInValue
						if a.hasCashInValue then -1 else 1

					when a.eligibleForCashIn isnt b.eligibleForCashIn
						if a.eligibleForCashIn then -1 else 1

					when a.hasLiveEvent isnt b.hasLiveEvent
						if a.hasLiveEvent then -1 else 1

					else return b.id - a.id

			# Only send back sorted ids since its the only thing needed
			couponIds = _.map respond, (resp, i) ->
				return { id: resp.id, order: i }

			return couponIds

		_couponHasLiveEvent: (coupon) ->
			outcomes = CouponOutcomesRepository.getOutcomesByCouponId coupon.get('id')
			for outcome in outcomes
				event = EventsRepository.get outcome.get('eventId')
				if event? and event.get('state') is 'STARTED' then return true
			return false

		_couponHasCashInValue: (coupon, hasLiveEvent) ->
			unless hasLiveEvent then return false
			unless coupon.get('eligibleForCashIn') then return false
			couponOutcome = CouponOutcomesRepository.getOutcomesByCouponId(coupon.get('id'))[0]
			betoffer = BetoffersRepository.get couponOutcome.get('betofferId')

			unless betoffer then return false
			if betoffer.get('closed') or betoffer.get('suspended')
				return false
			return true


		_updateOucomeOddsSubscription: ->
			couponOutcomeIds = _.uniq _.map CouponOutcomesRepository.getOutcomesEligibleForCashin(), (outcome) ->
				return outcome.get('outcomeId')

			intersect = _.intersection couponOutcomeIds, @couponOutcomeIds
			if intersect.length is couponOutcomeIds.length then return

			if @outcomeOddsSubscription
				OutcomesRepository.removeSubscription OutcomesRepository.OUTCOME_ODDS, @outcomeOddsSubscription

			if couponOutcomeIds.length > 0
				@outcomeOddsSubscription =
					pollingInterval: 5000
					params:
						includeLive: true
						ids: couponOutcomeIds

				OutcomesRepository.addSubscription OutcomesRepository.OUTCOME_ODDS, @outcomeOddsSubscription

				@couponOutcomeIds = couponOutcomeIds


		_onDiffInRepository: (dataDiff) =>
			do @_produceData
			do @_updateOucomeOddsSubscription


		SUBSCRIPTION_KEYS: [SubscriptionKeys.BETFEEDBACK]
