Vigor = require '../../../../dist/backbone.vigor'
assert = require 'assert'
sinon = require 'sinon'

describe 'When vaildating a contract', ->
  afterEach ->
    Vigor.setup { validateContract: false }

  it 'it should return early (and undefined) if Vigor.settings.validateContract is set to false', ->
    Vigor.setup { validateContract: false }
    valid = Vigor.helpers.validateContract { prop: 'string' }, { prop: 1 }, 'id123'
    assert.equal valid, undefined

  it 'it should validate contracts if Vigor.settings.validateContract is set to true', ->
    Vigor.setup { validateContract: true }
    valid = Vigor.helpers.validateContract { prop: 'string' }, { prop: 'string' }, 'id123'
    assert.equal valid, true

  describe 'and comparing contract to incomming data', ->
    it 'it should throw an error if the contract is not defined', ->
      Vigor.setup { validateContract: true }
      errorFn = -> Vigor.helpers.validateContract undefined, { prop: 'string' }, 'id123'
      assert.throws (-> errorFn()), /The id123 does not have any contract specified/

    it 'it should throw an error if the incomming data is not defined', ->
      Vigor.setup { validateContract: true }
      errorFn = -> Vigor.helpers.validateContract { prop: 'string' }, undefined, 'id123'
      assert.throws (-> errorFn()), /id123 is trying to validate the contract but does not recieve any data to compare against the contract/

    it 'it should throw an error if the contract expects an array but get something else', ->
      Vigor.setup { validateContract: true }
      errorFn = -> Vigor.helpers.validateContract [], {}, 'id123'
      assert.throws (-> errorFn()), /id123's compared data is supposed to be an array but is a object/

      errorFn = -> Vigor.helpers.validateContract [], 'string', 'id123'
      assert.throws (-> errorFn()), /id123's compared data is supposed to be an array but is a string/

      errorFn = -> Vigor.helpers.validateContract [], 123, 'id123'
      assert.throws (-> errorFn()), /id123's compared data is supposed to be an array but is a number/

      errorFn = -> Vigor.helpers.validateContract [], true, 'id123'
      assert.throws (-> errorFn()), /id123's compared data is supposed to be an array but is a boolean/

    it 'it does not throw an error if the contract expects an array and get an array', ->
      Vigor.setup { validateContract: true }
      valid = Vigor.helpers.validateContract [], [], 'id123'
      assert.ok

    it 'it should throw an error if the contract expects an object but gets an array', ->
      Vigor.setup { validateContract: true }
      errorFn = -> Vigor.helpers.validateContract {}, [], 'id123'
      assert.throws (-> errorFn()), /id123's compared data is supposed to be an object but is an array/

    it 'it should not throw an error if the contract expects an object and gets an object', ->
      Vigor.setup { validateContract: true }
      valid = Vigor.helpers.validateContract {}, {}, 'id123'
      assert.ok

    describe 'if validating an object', ->
      it 'it should throw an error if the compared data contains more keys than the contract', ->
        Vigor.setup { validateContract: true }
        contract =
          key1: 'val1'

        dataToCompare =
          key1: 'val1'
          key2: 'val2'

        errorFn = -> Vigor.helpers.validateContract contract, dataToCompare, 'id123', 'producing'
        assert.throws (-> errorFn()), /id123 is producing more data then what is specified in the contract/


      it 'it should throw an error if the compared data contains less keys than the contract', ->
        Vigor.setup { validateContract: true }
        contract =
          key1: 'val1'
          key2: 'val2'

        dataToCompare =
          key1: 'val1'

        errorFn = -> Vigor.helpers.validateContract contract, dataToCompare, 'id123', 'producing'
        assert.throws (-> errorFn()), /id123 is producing less data then what is specified in the contract/

      it 'it should not throw an error if the compared data contains the same number of keys as the contract', ->
        Vigor.setup { validateContract: true }
        contract =
          key1: 'val1'
          key2: 'val2'

        dataToCompare =
          key1: 'val1'
          key2: 'val2'

        valid = Vigor.helpers.validateContract contract, dataToCompare, 'id123', 'producing'
        assert.ok

      it 'it should throw an error if the compared data has the correct number of keys but is missing a specific key', ->
        Vigor.setup { validateContract: true }
        contract =
          key1: 'val1'

        dataToCompare =
          key2: 'val1'

        errorFn = -> Vigor.helpers.validateContract contract, dataToCompare, 'id123', 'producing'
        assert.throws (-> errorFn()), /id123 has data but is missing the key: key1/

      it 'it should throw an error if the compared data types does not match the contract', ->
        Vigor.setup { validateContract: true }
        contract =
          key1: 'val1'

        dataToCompare =
          key1: 123

        errorFn = -> Vigor.helpers.validateContract contract, dataToCompare, 'id123', 'producing'
        assert.throws (-> errorFn()), /id123 is producing data of the wrong type according to the contract, key1, expects string but gets number/
