import {Producer, Repository, Subscription} from '../../../dist/vigor';
import assert from 'assert';
import sinon from 'sinon';

const KEY1 = {
  key: 'dummy',
  contract: {
    key1: 'string'
  }
};

const KEY2 = {
  key: 'ymmud',
  contract: {
    key1: 'string'
  }
};

const INVALID_SUBSCRIPTION_KEY = {
  key: 'invalid-key',
  contract: {
    key1: 'string'
  }
};

class DummyProducer extends Producer {
  get PRODUCTION_KEY() {
    return KEY1;
  }
}

class DummyRepository extends Repository {}

describe('A Producer', () => {
  it('adds a component', () => {
    const producer = new DummyProducer();
    const componentIdentifier = new Subscription('foo', sinon.spy(), {});

    producer.addComponent(componentIdentifier);

    const componentsForKey = producer.registeredComponents;
    assert.equal(Object.keys(componentsForKey).length, 1);
    assert.equal(componentsForKey[componentIdentifier.id], componentIdentifier);
  });

  it('ignores calls to add a component more than once', () => {
    const producer = new DummyProducer();
    const componentIdentifier = new Subscription('foo', sinon.spy(), {});

    producer.addComponent(componentIdentifier);
    producer.addComponent(componentIdentifier);

    const componentsForKey = producer.registeredComponents;
    assert.equal(Object.keys(componentsForKey).length, 1);
    assert.equal(componentsForKey[componentIdentifier.id], componentIdentifier);
  });

  it('calls subscribeToRepositories when the first component is added', () => {
    const producer = new DummyProducer();
    const componentIdentifier = new Subscription('foo', sinon.spy(), {});

    producer.subscribeToRepositories = sinon.spy();
    producer.addComponent(componentIdentifier);

    assert(producer.subscribeToRepositories.calledOnce);
  });

  it('subscribes to repositories', () => {
    const producer = new DummyProducer();
    producer.onDiffInRepository = sinon.spy();
    const dummyRepository = new DummyRepository();
    producer.repositories = [
      dummyRepository
    ];

    const data = {};

    producer.subscribeToRepositories();
    dummyRepository.trigger(Repository.prototype.REPOSITORY_DIFF, data);

    assert(producer.onDiffInRepository.calledOnce);
  });

  it('subscribes to repositories with custom callbacks', () => {
    const producer = new DummyProducer();
    producer.dummyRepositoryCallback = sinon.spy();
    const dummyRepository = new DummyRepository();
    producer.repositories = [
      {
        repository: dummyRepository,
        callback: 'dummyRepositoryCallback'
      }
    ];

    const data = {};

    producer.subscribeToRepositories();
    dummyRepository.trigger(Repository.prototype.REPOSITORY_DIFF, data);

    assert(producer.dummyRepositoryCallback.calledOnce);
  });

  it('throws an error on unexpected format of producer repositories definitions', () => {
    const producer = new DummyProducer();
    producer.repositories = [
      {
        repo: 'foo',
        call: 'dummyRepositoryCallback'
      }
    ];

    const errorFn = () => producer.subscribeToRepositories();
    assert.throws((() => errorFn()), "unexpected format of producer repositories definition");
  });

  it('does not call subscribeToRepositories when a second component is added', () => {
    const producer = new DummyProducer();
    producer.subscribeToRepositories = sinon.spy();
    const componentIdentifier = new Subscription('foo', sinon.spy(), {});
    const componentIdentifier2 = new Subscription('bar', sinon.spy(), {});

    producer.addComponent(componentIdentifier);
    producer.addComponent(componentIdentifier2);

    assert(producer.subscribeToRepositories.calledOnce);
  });

  it('calls unsubscribeFromRepositories when the last component is removed', () => {
    const producer = new DummyProducer();
    producer.unsubscribeFromRepositories = sinon.spy();

    const componentId = 'foo';
    const componentIdentifier = new Subscription(componentId, sinon.spy(), {});

    producer.addComponent(componentIdentifier);
    producer.removeComponent(componentId);

    assert(producer.unsubscribeFromRepositories.calledOnce);
  });

  it('does not call unsubscribeFromRepositories when there are still components subscribed', () => {
    const producer = new DummyProducer();
    producer.unsubscribeFromRepositories = sinon.spy();

    const componentId = 'foo';
    const componentId2 = 'bar';

    const componentIdentifier = new Subscription(componentId, sinon.spy(), {});
    const componentIdentifier2 = new Subscription(componentId2, sinon.spy(), {});

    producer.addComponent(componentIdentifier);
    producer.addComponent(componentIdentifier2);
    producer.removeComponent(componentId);

    assert(producer.unsubscribeFromRepositories.notCalled);
  });

  it('unsubscribes from repositories', () => {
    const producer = new DummyProducer();
    producer.onDiffInRepository = sinon.spy();
    producer.dummyRepositoryCallback = sinon.spy();
    const dummyRepository = new DummyRepository();
    const dummyRepository2 = new DummyRepository();

    producer.repositories = [
      dummyRepository
    ];

    const data = {};

    producer.subscribeToRepositories();
    producer.unsubscribeFromRepositories();

    dummyRepository.trigger(Repository.prototype.REPOSITORY_DIFF, data);

    assert(producer.onDiffInRepository.notCalled);
  });

  it('unsubscribes from repositories with custom callbacks', () => {
    const producer = new DummyProducer();
    producer.onDiffInRepository = sinon.spy();
    producer.dummyRepositoryCallback = sinon.spy();
    const dummyRepository = new DummyRepository();
    producer.repositories = [
      {
        repository: dummyRepository,
        callback: 'dummyRepositoryCallback'
      }
    ];

    const data = {};

    producer.subscribeToRepositories();
    producer.unsubscribeFromRepositories();
    dummyRepository.trigger(Repository.prototype.REPOSITORY_DIFF, data);

    assert(producer.onDiffInRepository.notCalled);
    assert(producer.dummyRepositoryCallback.notCalled);
  });

  it('produces data on repository diff', () => {
    const producer = new DummyProducer();
    producer.produceData = sinon.spy();

    producer.onDiffInRepository();

    assert(producer.produceData.calledOnce);
  });

  it('removes a component', () => {
    const producer = new DummyProducer();
    const componentIdentifier = new Subscription('foo', sinon.spy(), {});

    producer.addComponent(componentIdentifier);
    producer.removeComponent(componentIdentifier.id);

    assert.equal(Object.keys(producer.registeredComponents).length, 0);
  });

  it('does not remove components if they are not added', () => {
    const producer = new DummyProducer();
    const componentIdentifier = new Subscription('foo', sinon.spy(), {});

    producer.removeComponent(componentIdentifier.id);
    assert.equal(Object.keys(producer.registeredComponents).length, 0);
  });

  it('does not remove unrelated components', () => {
    const producer = new DummyProducer();
    const componentIdentifier1 = new Subscription('foo', sinon.spy(), {});
    const componentIdentifier2 = new Subscription('bar', sinon.spy(), {});

    producer.addComponent(componentIdentifier1);
    producer.addComponent(componentIdentifier2);
    producer.removeComponent(componentIdentifier2.id);

    assert.equal(Object.keys(producer.registeredComponents).length, 1);
    assert.equal(producer.registeredComponents[componentIdentifier1.id], componentIdentifier1);
  });

  it('produces data', () => {
    const producer = new DummyProducer();
    const callback = sinon.spy();
    const producedData = {};
    const componentIdentifier = new Subscription('foo', callback, {});
    const data = { key1: '' };
    const currentData = sinon.stub(producer, "currentData", () => data);

    producer.addComponent(componentIdentifier);

    assert(callback.calledOnce);

    const args = callback.args[0];
    assert.equal(args.length, 1);
    assert.equal(args[0], data);
  });

  it('calls decorate when producing data', () => {
    const producer = new DummyProducer();
    const originalData = {};
    const decoratedData = {};

    sinon.stub(producer, 'decorate', (data) => {
      assert.equal(data, originalData);
      return decoratedData;
    });

    producer.produce(originalData);
    assert(producer.decorate.calledOnce);
  });

  it('calls the callback with the decorated data', () => {
    const producer = new DummyProducer();
    const decoratedData = {};
    const callback = sinon.spy();
    const componentIdentifier = new Subscription('foo', callback, {});

    sinon.stub(producer, 'decorate', data => decoratedData);

    producer.addComponent(componentIdentifier);

    assert(callback.calledOnce);
    assert(callback.calledWith(decoratedData));
  });

  it('passes the data through the decorators in order', () => {
    const originalData = {};
    const decorator1 = sinon.spy((data) => {
      assert.equal(data, originalData);
      data.decorator1 = true;
    });

    const decorator2 = sinon.spy((data) => {
      assert.equal(data.decorator1, true);
      data.decorator2 = true;
    });

    const producer = new DummyProducer();
    producer.decorators = [decorator1, decorator2];

    const currentData = sinon.stub(producer, "currentData", () => originalData);
    const callback = sinon.spy();
    const componentIdentifier = new Subscription('foo', callback, {});

    producer.addComponent(componentIdentifier);

    assert(decorator1.calledOnce);
    assert(decorator2.calledOnce);
    assert(callback.calledOnce);
    const args = callback.args[0];
    assert.equal(args.length, 1);
    const data = args[0];
    assert.equal(data.decorator2, true);
  });

  it('throws an error if the subscription key does not have a contract', () => {
    class DummyProducer2 {
      get PRODUCTION_KEY() {
        return KEY1;
      }
    }
    const producer = new DummyProducer2();
    const errorFn = () => producer.produce({});

    assert.throws(errorFn, `The subscriptionKey ${producer.PRODUCTION_KEY.key} doesn't have a contract specified`);
  });
});
