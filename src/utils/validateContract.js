import _ from 'underscore';
import {settings} from '../settings';
// **ValidateContract**<br/>
// @param [contract]: Object<br/>
// The contract to validate the data against. The contract should match the shape of the expected data object and
// contain primitive values of the same type as the expected values.
//
// @param [dataToCompare]: Object<br/>
// The data to validate.
//
// @param [comparatorId]: String<br/>
// A human-readable name for the comparator, to be used to make nice error messages when things go wrong.
//
// @param [verb]: String<br/>
// A human-readable name for the action that the comparator is trying to achieve, to be used to make nice error
// messages when things go wrong. The default value is `receiving`.
//
// @returns `true` if the data is valid according to the given contract, `false` otherwise.
//
// Validates the given data according to the given contract. If the shape or any of the primitive types of the data
// object differ from the contract object, the contract is violated and this function returns `false`. Otherwise, it
// returns `true`.
const validateContract = function(contract, dataToCompare, comparatorId, verb = 'recieving') {
  if (!settings.shouldValidateContract) { return; }
  if (!contract) {
    throw new Error(`The ${comparatorId} does not have any contract specified`);
  }

  if (!dataToCompare) {
    throw new Error(`${comparatorId} is trying to validate the contract but does not recieve any data to compare against the contract`);
  }

  if (_.isArray(contract) && _.isArray(dataToCompare) === false) {
    throw new Error(`${comparatorId}'s compared data is supposed to be an array but is a ${typeof dataToCompare}`);
  }

  if (_.isObject(contract) && _.isArray(contract) === false && _.isArray(dataToCompare)) {
    throw new Error(`${comparatorId}'s compared data is supposed to be an object but is an array`);
  }

  if (_.isObject(contract) && _.isArray(contract) === false) {
    const contractKeyCount = _.keys(contract).length;
    const dataKeyCount = _.keys(dataToCompare).length;

    if (dataKeyCount > contractKeyCount) {
      throw new Error(`${comparatorId} is ${verb} more data then what is specified in the contract`, contract,dataToCompare);
    } else if (dataKeyCount < contractKeyCount) {
      throw new Error(`${comparatorId} is ${verb} less data then what is specified in the contract`, contract,dataToCompare);
    }
  }

  for (let key in contract) {
    if (contract.hasOwnProperty(key)) {
      const val = contract[key];
      if (!(key in dataToCompare)) {
        throw new Error(`${comparatorId} has data but is missing the key: ${key}`);
      }

      if (val !== null || val !== undefined) {
        if (typeof dataToCompare[key] !== typeof val) {
          throw new Error(`${comparatorId} is ${verb} data of the wrong type according to the contract, ${key}, expects ${typeof val} but gets ${typeof dataToCompare[key]}`);
        }
      }
    }
  }

  return true;
};

export default validateContract;
