Vigor = require '../../../dist/vigor'
assert = require 'assert'
sinon = require 'sinon'

dataCommunicationManager = Vigor.DataCommunicationManager
ComponentViewModel = Vigor.ComponentViewModel
producerManager = Vigor.ProducerManager

describe 'ComponentViewModel', ->
  beforeEach ->
    sinon.stub producerManager, 'subscribeComponentToKey'
    sinon.stub producerManager, 'unsubscribeComponentFromKey'
    sinon.stub producerManager, 'unsubscribeComponent'

  afterEach ->
    do producerManager.subscribeComponentToKey.restore
    do producerManager.unsubscribeComponentFromKey.restore
    do producerManager.unsubscribeComponent.restore

  describe 'constructor', ->
    it 'should add a unique id as a public property', ->
      uniqueId = sinon.spy _, 'uniqueId'
      viewModelOne = new ComponentViewModel()
      viewModelTwo = new ComponentViewModel()
      assert.notEqual viewModelOne.id, viewModelTwo.id
      assert uniqueId.calledTwice

  describe 'dispose', ->
    it 'should call unsubscribeAll', ->
      viewModel = new ComponentViewModel()
      dispose = sinon.spy viewModel, 'unsubscribeAll'
      viewModel.dispose()
      assert dispose.called

  describe 'subscribe', ->
    it 'should call dataCommunicationManager.subscribe with id, key, callback and options', ->
      viewModel = new ComponentViewModel()
      key = 'dummy'
      cb = ->
      options = {}
      subscribe = sinon.spy dataCommunicationManager, 'subscribe'

      viewModel.subscribe key, cb, options

      assert subscribe.calledWith viewModel.id, key, cb, options
      subscribe.restore()

  describe 'unsubscribe', ->
    it 'should call dataCommunicationManager.unsubscribe with id, key', ->
      viewModel = new ComponentViewModel()
      key = 'dummy'
      unsubscribe = sinon.spy dataCommunicationManager, 'unsubscribe'

      viewModel.unsubscribe key

      assert unsubscribe.calledWith viewModel.id, key
      unsubscribe.restore()

  describe 'unsubscribeAll', ->
    it 'should call dataCommunicationManager.unsubscribeAll with id', ->
      viewModel = new ComponentViewModel()
      key = 'dummy'
      unsubscribeAll = sinon.spy dataCommunicationManager, 'unsubscribeAll'

      viewModel.unsubscribeAll key

      assert unsubscribeAll.calledWith viewModel.id
      unsubscribeAll.restore()

  describe 'validateContract', ->
    it 'should call Vigor.helpers.validateContract with contract, incommingData and id', ->
      viewModel = new ComponentViewModel()
      contract =
        key: 'val'

      incommingData =
        key: 'val'

      validateContract = sinon.spy Vigor.helpers, 'validateContract'

      viewModel.validateContract contract, incommingData

      assert validateContract.calledWith contract, incommingData, viewModel.id
      validateContract.restore()

