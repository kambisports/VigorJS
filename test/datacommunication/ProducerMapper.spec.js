import {ProducerMapper, Producer} from '../../dist/vigor';
import assert from 'assert';
import sinon from 'sinon';

const KEY = {
  key: 'dummy',
  contract: {
    val1: true,
    val2: undefined
  }
};

const KEY2 = {
  key: 'myyud',
  contract: {
    val1: true,
    val2: undefined
  }
};


class DummyProducer extends Producer {
  get PRODUCTION_KEY() {
    return KEY;
  }

  subscribe() {}
  dispose() {}
  subscribeToRepositories() {}
}


describe('A ProducerMapper', () => {

  afterEach(() => {
    ProducerMapper.reset();
  });

  describe('given a registered subscription key', () => {
    it('it should return a producerClass', () => {
      ProducerMapper.register(DummyProducer);
      const producer = ProducerMapper.producerClassForKey(KEY);
      assert.equal(producer, DummyProducer);
    });

    it('it should return a producer', () => {
      ProducerMapper.register(DummyProducer);
      const producer = ProducerMapper.producerForKey(KEY);
      assert(producer instanceof DummyProducer);
    });
  });

  describe('given a unregistered subscription key', () => {
    it('it should throw a "No producer found for subscription" error', () => {
      ProducerMapper.register(DummyProducer);
      const errorFn = () => ProducerMapper.producerForKey(KEY2);
      assert.throws((() => errorFn()), `No producer found for subscription ${KEY2.key}`);
    });
  });

  describe('when trying to find a producer when no producers are registered', () => {
    it('it should throw a "There are No producers registered" error', () => {
      const errorFn = () => ProducerMapper.producerClassForKey(KEY);
      assert.throws((() => errorFn()), /There are no producers registered - register producers through the ProducerManager/);
    });
  });

  describe('when trying to register a producer with an existing key', () => {
    it('should throw an "already registered" error', () => {
      const errorFn = () => ProducerMapper.register(Object.create({ PRODUCTION_KEY: KEY }));
      assert.throws((() => errorFn()), `A producer for the key ${KEY} is already registered`);
    });
  });


  describe('reset', () => {
    it('should reset the mapper', () => {
      ProducerMapper.register(DummyProducer);
      ProducerMapper.reset();
      assert.equal(ProducerMapper.producers.length, 0);

      const errorFn = () => ProducerMapper.producerClassForKey(DummyProducer.prototype.PRODUCTION_KEY);
      assert.throws((() => errorFn()), `No producer found for subscription ${DummyProducer.prototype.PRODUCTION_KEY.key}`);
    });
  });
});
