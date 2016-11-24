import { ComponentViewModel, ProducerManager } from '../../dist/vigor';
import _ from 'underscore';
import assert from 'assert';
import sinon from 'sinon';

describe('ComponentViewModel', () => {
  beforeEach(() => {
    sinon.stub(ProducerManager, 'subscribe');
    sinon.stub(ProducerManager, 'unsubscribe');
    sinon.stub(ProducerManager, 'unsubscribeAll');
  });

  afterEach(() => {
    ProducerManager.subscribe.restore();
    ProducerManager.unsubscribe.restore();
    ProducerManager.unsubscribeAll.restore();
  });

  // describe('constructor', () => {
  //   it('should add a unique id as a public property', () => {
  //     const uniqueId = sinon.spy(_, 'uniqueId');
  //     const viewModelOne = new ComponentViewModel();
  //     const viewModelTwo = new ComponentViewModel();
  //     assert.notStrictEqual(viewModelOne.id, viewModelTwo.id);
  //     console.log(_.uniqueId.callCount);
  //     // assert(uniqueId.calledTwice);
  //   });
  // });

  describe('dispose', () => {
    it('should call unsubscribeAll', () => {
      const viewModel = new ComponentViewModel();
      const dispose = sinon.spy(viewModel, 'unsubscribeAll');
      viewModel.dispose();
      assert(dispose.called);
    });
  });

  describe('subscribe', () => {
    it('should call ProducerManager.subscribe with id, key, callback and options', () => {
      const viewModel = new ComponentViewModel();
      const key = 'dummy';
      const cb = () => {};
      const options = {};
      viewModel.subscribe(key, cb, options);
      assert(ProducerManager.subscribe.calledWith(viewModel.id, key, cb, options));
    });
  });

  describe('unsubscribe', () => {
    it('should call ProducerManager.unsubscribe with id, key', () => {
      const viewModel = new ComponentViewModel();
      const key = 'dummy';

      viewModel.unsubscribe(key);

      assert(ProducerManager.unsubscribe.calledWith(viewModel.id, key));
    });
  });

  describe('unsubscribeAll', () => {
    it('should call ProducerManager.unsubscribeAll with id', () => {
      const viewModel = new ComponentViewModel();
      const key = 'dummy';

      viewModel.unsubscribeAll(key);

      assert(ProducerManager.unsubscribeAll.calledWith(viewModel.id));
    });
  });

  // describe('validateContract', () => {
  //   it('should call Vigor.helpers.validateContract with contract, incommingData and id', () => {
  //     const viewModel = new ComponentViewModel();
  //     const contract = {key: 'val'};
  //     const incommingData = {key: 'val'};
  //     const validateContract = sinon.spy(Vigor.helpers, 'validateContract');

  //     viewModel.validateContract(contract, incommingData);

  //     assert(validateContract.calledWith(contract, incommingData, viewModel.id));
  //     validateContract.restore();
  //   });
  // });
});

