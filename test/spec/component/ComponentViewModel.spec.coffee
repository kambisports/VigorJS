Vigor = require '../../../dist/vigor'
assert = require 'assert'
sinon = require 'sinon'

ComponentViewModel = Vigor.ComponentViewModel
producerManager = Vigor.ProducerManager

describe 'ComponentViewModel', ->
  beforeEach ->
    sinon.stub producerManager, 'subscribe'
    sinon.stub producerManager, 'unsubscribe'
    sinon.stub producerManager, 'unsubscribeAll'

  afterEach ->
    do producerManager.subscribe.restore
    do producerManager.unsubscribe.restore
    do producerManager.unsubscribeAll.restore

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
    it 'should call producerManager.subscribe with id, key, callback and options', ->
      viewModel = new ComponentViewModel()
      key = 'dummy'
      cb = ->
      options = {}

      viewModel.subscribe key, cb, options

      assert producerManager.subscribe.calledWith viewModel.id, key, cb, options

  describe 'unsubscribe', ->
    it 'should call producerManager.unsubscribe with id, key', ->
      viewModel = new ComponentViewModel()
      key = 'dummy'

      viewModel.unsubscribe key

      assert producerManager.unsubscribe.calledWith viewModel.id, key

  describe 'unsubscribeAll', ->
    it 'should call producerManager.unsubscribeAll with id', ->
      viewModel = new ComponentViewModel()
      key = 'dummy'

      viewModel.unsubscribeAll key

      assert producerManager.unsubscribeAll.calledWith viewModel.id

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

