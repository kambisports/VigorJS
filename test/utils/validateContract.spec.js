import {validateContract, setup, settings} from '../../dist/vigor';
import assert from 'assert';
import sinon from 'sinon';

describe('When vaildating a contract', () => {
  afterEach(() => {
    setup({ shouldValidateContract: false });
  });

  it('it should return early (and undefined) if validateContract is set to false', () => {
    setup({ shouldValidateContract: false });
    let valid = validateContract({ prop: 'string' }, { prop: 1 }, 'id123');
    assert.equal(valid, undefined);
  });

  it('it should validate contracts if validateContract is set to true', () => {
    setup({ shouldValidateContract: true });
    let valid = validateContract({ prop: 'string' }, { prop: 'string' }, 'id123');
    assert.equal(valid, true);
  });

  describe('and comparing contract to incomming data', () => {
    it('it should throw an error if the contract is not defined', () => {
      setup({ shouldValidateContract: true });
      let errorFn = () => validateContract(undefined, { prop: 'string' }, 'id123');
      assert.throws((() => errorFn()), /The id123 does not have any contract specified/);
    });

    it('it should throw an error if the incomming data is not defined', () => {
      setup({ shouldValidateContract: true });
      let errorFn = () => validateContract({ prop: 'string' }, undefined, 'id123');
      assert.throws((() => errorFn()), /id123 is trying to validate the contract but does not recieve any data to compare against the contract/);
    });

    it('it should throw an error if the contract expects an array but get something else', () => {
      setup({ shouldValidateContract: true });
      let errorFn = () => validateContract([], {}, 'id123');
      assert.throws((() => errorFn()), /id123's compared data is supposed to be an array but is a object/);

      errorFn = () => validateContract([], 'string', 'id123');
      assert.throws((() => errorFn()), /id123's compared data is supposed to be an array but is a string/);

      errorFn = () => validateContract([], 123, 'id123');
      assert.throws((() => errorFn()), /id123's compared data is supposed to be an array but is a number/);

      errorFn = () => validateContract([], true, 'id123');
      assert.throws((() => errorFn()), /id123's compared data is supposed to be an array but is a boolean/);
    });

    it('it does not throw an error if the contract expects an array and get an array', () => {
      setup({ shouldValidateContract: true });
      let valid = validateContract([], [], 'id123');
      assert.ok;
    });

    it('it should throw an error if the contract expects an object but gets an array', () => {
      setup({ shouldValidateContract: true });
      let errorFn = () => validateContract({}, [], 'id123');
      assert.throws((() => errorFn()), /id123's compared data is supposed to be an object but is an array/);
    });

    it('it should not throw an error if the contract expects an object and gets an object', () => {
      setup({ shouldValidateContract: true });
      let valid = validateContract({}, {}, 'id123');
      assert.ok;
    });

    describe('if validating an object', () => {
      it('it should throw an error if the compared data contains more keys than the contract', () => {
        setup({ shouldValidateContract: true });
        let contract =
          {key1: 'val1'};

        let dataToCompare = {
          key1: 'val1',
          key2: 'val2'
        };

        let errorFn = () => validateContract(contract, dataToCompare, 'id123', 'producing');
        assert.throws((() => errorFn()), /id123 is producing more data then what is specified in the contract/);
      });


      it('it should throw an error if the compared data contains less keys than the contract', () => {
        setup({ shouldValidateContract: true });
        let contract = {
          key1: 'val1',
          key2: 'val2'
        };

        let dataToCompare =
          {key1: 'val1'};

        let errorFn = () => validateContract(contract, dataToCompare, 'id123', 'producing');
        assert.throws((() => errorFn()), /id123 is producing less data then what is specified in the contract/);
      });

      it('it should not throw an error if the compared data contains the same number of keys as the contract', () => {
        setup({ shouldValidateContract: true });
        let contract = {
          key1: 'val1',
          key2: 'val2'
        };

        let dataToCompare = {
          key1: 'val1',
          key2: 'val2'
        };

        let valid = validateContract(contract, dataToCompare, 'id123', 'producing');
        assert.ok;
      });

      it('it should throw an error if the compared data has the correct number of keys but is missing a specific key', () => {
        setup({ shouldValidateContract: true });
        let contract =
          {key1: 'val1'};

        let dataToCompare =
          {key2: 'val1'};

        let errorFn = () => validateContract(contract, dataToCompare, 'id123', 'producing');
        assert.throws((() => errorFn()), /id123 has data but is missing the key: key1/);
      });

      return it('it should throw an error if the compared data types does not match the contract', () => {
        setup({ shouldValidateContract: true });
        let contract =
          {key1: 'val1'};

        let dataToCompare =
          {key1: 123};

        let errorFn = () => validateContract(contract, dataToCompare, 'id123', 'producing');
        assert.throws((() => errorFn()), /id123 is producing data of the wrong type according to the contract, key1, expects string but gets number/);
      });
    });
  });
});
