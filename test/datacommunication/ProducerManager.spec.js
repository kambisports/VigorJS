import {Producer, ProducerManager, ProducerMapper, SubscriptionKeys} from '../../dist/vigor';
import assert from 'assert';
import sinon from 'sinon';

SubscriptionKeys.extend({
  EXAMPLE_KEY1: {
    key: 'example-key',
    contract: {
      val1: [],
      val2: undefined,
      val3: undefined,
      val4: false,
      val5: true,
      val6: {},
      val7: 'string',
      val8: 123
    }
  },

  EXAMPLE_KEY2: {
    key: 'example-key2',
    contract: {
      val1: 'string'
    }
  }
});

const INVALID_SUBSCRIPTION_KEY = 'invalid-key';

class ProducerStub extends Producer {
  subscribe() {}
  unsubscribe() {}
  subscribeToRepositories() {}
  dispose() {}
}

class DummyProducer1 extends ProducerStub {
  get PRODUCTION_KEY() {
    return SubscriptionKeys.EXAMPLE_KEY1;
  }
}

class DummyProducer2 extends ProducerStub {
  get PRODUCTION_KEY() {
    return SubscriptionKeys.EXAMPLE_KEY2;
  }
}

const addComponent = sinon.spy(DummyProducer1.prototype, 'addComponent');
const removeComponent = sinon.spy(DummyProducer1.prototype, 'removeComponent');
const removeComponent2 = sinon.spy(DummyProducer2.prototype, 'removeComponent');

describe('A ProducerManager', () => {
  beforeEach(() => {
    ProducerManager.registerProducers([DummyProducer1, DummyProducer2]);
  });

  afterEach(() => {
    ProducerMapper.reset()
  });

  describe('given a valid subscription key', () => {
    it('should return the producer', () => {
      const producer = ProducerManager.producerForKey(SubscriptionKeys.EXAMPLE_KEY1);
      assert.ok(producer instanceof DummyProducer1);
    });

    it('should return the correct producer', () => {
      const producer1 = ProducerManager.producerForKey(SubscriptionKeys.EXAMPLE_KEY1);
      const producer2 = ProducerManager.producerForKey(SubscriptionKeys.EXAMPLE_KEY2);
      assert.notEqual(producer2, producer1);
    });

    describe('to subscribe', () => {
      it('should call the producer\'s addComponent method', () => {

        addComponent.reset();
        const callback = () => {};
        const id = 123;
        const options = {};
        ProducerManager.subscribe(id, SubscriptionKeys.EXAMPLE_KEY1, callback, options);

        const instance = addComponent.thisValues[0];
        const args = addComponent.args[0];

        assert(addComponent.calledOnce);
        assert.ok(instance instanceof DummyProducer1);

        assert.equal(args.length, 1);
        const subscription = args[0];
        assert.equal(subscription.id, id);
        assert.equal(subscription.callback, callback);
        assert.equal(subscription.options, options);
      });

      it('should add multiple components for same subscription', () => {
        addComponent.reset();
        const component1 = {
          id: 123,
          key: SubscriptionKeys.EXAMPLE_KEY1,
          callback() {},
          options: {}
        };

        const component2 = {
          id: 456,
          key: SubscriptionKeys.EXAMPLE_KEY1,
          callback() {},
          options: {}
        };

        ProducerManager.subscribe(component1.id, component1.key, component1.callback, component1.options);
        ProducerManager.subscribe(component2.id, component2.key, component2.callback, component2.options);

        assert(addComponent.calledTwice);
        const subscription = addComponent.lastCall.args[0];
        assert.equal(subscription.id, component2.id);
        assert.equal(subscription.callback, component2.callback);
        assert.equal(subscription.options, component2.options);
      });
    });

    describe('to unsubscribe', () => {
      it('should call the producer\'s removeComponent method', () => {
        const componentId = 'dummy';

        removeComponent.reset();
        ProducerManager.unsubscribe(componentId, SubscriptionKeys.EXAMPLE_KEY1);

        const instance = removeComponent.thisValues[0];
        const args = removeComponent.args[0];

        assert(removeComponent.calledOnce);
        assert.ok(instance instanceof DummyProducer1);

        assert.equal(args.length, 1);
         assert.equal(args[0], componentId);
      });
    });

    describe('to unsubscribe component completely', () => {
      it('should call all producers\' removeComponent method', () => {
        let componentId = 'dummy';

        removeComponent.reset();
        ProducerManager.unsubscribeAll(componentId);

        let instance = removeComponent.thisValues[0];
        let args = removeComponent.args[0];

        assert(removeComponent.calledOnce);
        assert.ok(instance instanceof DummyProducer1);

        assert.equal(args.length, 1);
        assert.equal(args[0], componentId);

        // make the same checks for the second producer
        instance = removeComponent2.thisValues[0];
        args = removeComponent2.args[0];

        assert(removeComponent2.calledOnce);
        assert.ok(instance instanceof DummyProducer2);

        assert.equal(args.length, 1);
        return assert.equal(args[0], componentId);
      });
    });

    describe('using subscribe', () => {
      it('should add multiple components for same subscription', () => {});
    });
  });
});
