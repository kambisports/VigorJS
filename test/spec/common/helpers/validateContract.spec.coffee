Vigor = require '../../../../dist/backbone.vigor'
assert = require 'assert'
sinon = require 'sinon'

describe 'validateContract', ->
  afterEach ->
    Vigor.setup { validateContract: false }

  it 'should return early (and undefined) if Vigor.settings.validateContract is set to false', ->
    Vigor.setup { validateContract: false }
    valid = Vigor.helpers.validateContract { prop: 'string' }, { prop: 1 }, 'id123'
    assert.equal valid, undefined

  it 'should validate contracts if Vigor.settings.validateContract is set to true', ->
    Vigor.setup { validateContract: true }
    valid = Vigor.helpers.validateContract { prop: 'string' }, { prop: 'string' }, 'id123'
    assert.equal valid, true

  describe 'when validating', ->
    it ' it throw an error if the contract is not defined', ->
      Vigor.setup { validateContract: true }
      errorFn = -> Vigor.helpers.validateContract undefined, { prop: 'string' }, 'id123'
      assert.throws (-> errorFn()), /The id123 does not have any contract specified/

    it ' it throw an error if the data to compare is not defined', ->
      Vigor.setup { validateContract: true }
      errorFn = -> Vigor.helpers.validateContract { prop: 'string' }, undefined, 'id123'
      assert.throws (-> errorFn()), /id123 is trying to validate the contract but does not recieve any data to compare against the contract/

    it ' it does not throw an error if the contract expects an array and get an array', ->
      Vigor.setup { validateContract: true }
      valid = Vigor.helpers.validateContract [], [], 'id123'
      assert.ok

    it ' it throw an error if the contract expects an array but get something else', ->
      Vigor.setup { validateContract: true }
      errorFn = -> Vigor.helpers.validateContract [], {}, 'id123'
      assert.throws (-> errorFn()), /id123's compared data is supposed to be an array but is a object/

      errorFn = -> Vigor.helpers.validateContract [], 'string', 'id123'
      assert.throws (-> errorFn()), /id123's compared data is supposed to be an array but is a string/

      errorFn = -> Vigor.helpers.validateContract [], 123, 'id123'
      assert.throws (-> errorFn()), /id123's compared data is supposed to be an array but is a number/

      errorFn = -> Vigor.helpers.validateContract [], true, 'id123'
      assert.throws (-> errorFn()), /id123's compared data is supposed to be an array but is a boolean/


