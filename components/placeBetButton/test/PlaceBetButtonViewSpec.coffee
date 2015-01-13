define [
	#'model/UserSettingsModel'
	#'components/placeBetButton/PlaceBetButtonView'
], (
	#UserSettingsModel
	#PlaceBetButtonView
) ->

	"use strict"

	describe 'PlaceBetButton View specification', ->

		#userSettingsModel = undefined
		#placeBetButtonView = undefined

		beforeEach ->
			#userSettingsModel = do UserSettingsModel.makeInstance
			#placeBetButtonView = new PlaceBetButtonView userSettingsModel


		describe 'Configuration', ->

			it 'should be able to hide the menu', ->
				expect(3).toBe 3


			it 'show settings info box only the first time', ->
