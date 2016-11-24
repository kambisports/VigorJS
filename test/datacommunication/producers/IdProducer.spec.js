import {IdProducer, Repository} from '../../../dist/vigor';
import assert from 'assert';
import sinon from 'sinon';

const KEY = {
  key: 'dummy',
  contract: {
    key1: 'string'
  }
};

class DummyRepository extends Repository {}

const dummyRepository1 = new DummyRepository();

class DummyProducer extends IdProducer {
  get PRODUCTION_KEY() {
    return KEY;
  }
  constructor() {
    super();
    this.repositories = [dummyRepository1];
    this.decorators = [];
  }
}

let dummyProducer = undefined;

describe('An IdProducer', () => {

  beforeEach(() => {
    dummyProducer = new DummyProducer()
  });

  it('should subscribe a component', () => {
    const componentId = 1;

    dummyProducer.subscribe({id: componentId});
    assert(dummyProducer.hasId(componentId));
  });

  it('should throw an error when the id type is wrong', () => {
    const componentId = 'a string';
    const errorFn = () => dummyProducer.subscribe({id: componentId});
    assert.throws(errorFn, `expected the subscription key to be a ${dummyProducer.idType} but got a ${typeof componentId}`);
  });

  it('should subscribe a component with the id returned by idForOptions', () => {
    const componentId = 1;
    const componentId2 = 2;

    sinon.stub(dummyProducer, 'idForOptions', () => componentId2);

    dummyProducer.subscribe({id: componentId});

    assert(dummyProducer.hasId(componentId2));
  });

  it('should unsubscribe a component', () => {
    const componentId = 1;
    const subscription = {id: componentId};

    dummyProducer.subscribe(subscription);
    dummyProducer.unsubscribe(subscription);

    assert(!dummyProducer.hasId(componentId));
  });


  it('should unsubscribe a component with the id returned by idForOptions', () => {
    const componentId = 1;
    const componentId2 = 2;
    const subscription = {id: componentId};

    sinon.stub(dummyProducer, 'idForOptions', () => componentId2);

    dummyProducer.subscribe(subscription);
    dummyProducer.unsubscribe(subscription);

    assert(!dummyProducer.hasId(componentId2));
  });


  it('should immediately produce when a component subscribes', () => {
    const componentId = 1;
    const subscription = {id: componentId};

    sinon.stub(dummyProducer, 'produce');

    dummyProducer.subscribe(subscription);

    assert(dummyProducer.produce.calledOnce);
    const args = dummyProducer.produce.args[0];
    assert((args.length === 1));
    assert(args[0].length === 1);
    assert(args[0][0] === componentId);
  });


  it('should eventually produce added items', (done) => {
    const componentId = 1;
    const subscription = {id: componentId};
    sinon.stub(dummyProducer, 'produce');

    dummyProducer.subscribe(subscription);
    dummyProducer.produce.restore();

    sinon.stub(dummyProducer, 'produce', function () {
      assert(arguments.length === 1);
      assert(arguments[0].length === 1);
      assert(arguments[0][0] === componentId);
      done();
    });

    dummyProducer.onDiffInRepository(dummyProducer.repositories[0], {
      added: [
        {id: subscription.id}
      ],
      removed: [],
      changed: []
    });
  });

  it('should eventually produce added items on the idForModel', (done) => {
    const componentId = 1;
    const subscription = {id: componentId};

    sinon.stub(dummyProducer, 'produce');
    sinon.stub(dummyProducer, 'idForModel').returns(componentId);


    dummyProducer.subscribe(subscription);

    dummyProducer.produce.restore();

    sinon.stub(dummyProducer, 'produce', function () {
      assert(arguments[0][0] === componentId);
      done();
    });

    dummyProducer.onDiffInRepository(dummyProducer.repositories[0], {
      added: [
        {id: 'foo'}
      ],
      removed: [],
      changed: []
    });
  });

  it('should not produce on added items that are not subscribed to', (done) => {
    const componentId = 1;

    sinon.stub(dummyProducer, 'produce', () => sinon.assert.fail());

    dummyProducer.onDiffInRepository(dummyProducer.repositories[0], {
      added: [
        {id: componentId}
      ],
      removed: [],
      changed: []
    });

    setTimeout(done, 250);
  });

  it('should allow idForModel to return an array for added items', (done) => {
    const componentId1 = 1;
    const componentId2 = 2;
    const subscription1 = {id: componentId1};
    const subscription2 = {id: componentId2};

    sinon.stub(dummyProducer, 'produce');
    sinon.stub(dummyProducer, 'idForModel').returns([componentId1, componentId2]);

    dummyProducer.subscribe(subscription1);
    dummyProducer.subscribe(subscription2);

    dummyProducer.produce.restore();

    sinon.stub(dummyProducer, 'produce', function(ids) {
      assert.deepEqual(ids, [componentId1, componentId2]);
      done();
    });

    dummyProducer.onDiffInRepository(dummyProducer.repositories[0], {
      added: [
        {id: 'foo'}
      ],
      removed: [],
      changed: []
    });
  });

  it('should eventually produce removed items', (done) => {
    const componentId = 1;
    const subscription = {id: componentId};

    sinon.stub(dummyProducer, 'produce');

    dummyProducer.subscribe(subscription);
    dummyProducer.produce.restore();

    sinon.stub(dummyProducer, 'produce', function () {
      assert(arguments[0][0] === componentId);
      done();
    });

    dummyProducer.onDiffInRepository(dummyProducer.repositories[0], {
      added: [],
      removed: [
        {id: subscription.id}
      ],
      changed: []
    });
  });

  it('should eventually produce removed items on the idForModel', (done) => {
    const componentId = 1;
    const subscription = {id: componentId};

    sinon.stub(dummyProducer, 'produce');
    sinon.stub(dummyProducer, 'idForModel').returns(componentId);


    dummyProducer.subscribe(subscription);

    dummyProducer.produce.restore();

    sinon.stub(dummyProducer, 'produce', function () {
      assert(arguments[0][0] === componentId);
      done();
    });

    dummyProducer.onDiffInRepository(dummyProducer.repositories[0], {
      added: [],
      removed: [
        {id: 'foo'}
      ],
      changed: []
    });
  });

  it('should not produce on removed items that are not subscribed to', (done) => {
    const componentId = 1;

    sinon.stub(dummyProducer, 'produce', () => sinon.assert.fail());

    dummyProducer.onDiffInRepository(dummyProducer.repositories[0], {
      added: [],
      removed: [
        {id: componentId}
      ],
      changed: []
    });

    setTimeout(done, 250);
  });


  it('should allow idForModel to return an array for removed items', (done) => {
    const componentId1 = 1;
    const componentId2 = 2;
    const subscription1 = {id: componentId1};
    const subscription2 = {id: componentId2};

    sinon.stub(dummyProducer, 'produce');
    sinon.stub(dummyProducer, 'idForModel').returns([componentId1, componentId2]);

    dummyProducer.subscribe(subscription1);
    dummyProducer.subscribe(subscription2);
    dummyProducer.produce.restore();

    sinon.stub(dummyProducer, 'produce', function(ids) {
      assert.deepEqual(ids, [componentId1, componentId2]);
      done();
    });

    dummyProducer.onDiffInRepository(dummyProducer.repositories[0], {
      added: [],
      removed: [
        {id: 'foo'}
      ],
      changed: []
    });
  });


  it('should eventually produce changed items', (done) => {
    const componentId = 1;
    const subscription = {id: componentId};

    sinon.stub(dummyProducer, 'produce');

    dummyProducer.subscribe(subscription);
    dummyProducer.produce.restore();

    sinon.stub(dummyProducer, 'produce', function () {
      assert(arguments[0][0] === componentId);
      done();
    });

    dummyProducer.onDiffInRepository(dummyProducer.repositories[0], {
      added: [],
      removed: [],
      changed: [
        {id: subscription.id}
      ]
    });
  });

  it('should eventually produce changed items on the idForModel', (done) => {
    const componentId = 1;
    const subscription = {id: componentId};

    sinon.stub(dummyProducer, 'produce');
    sinon.stub(dummyProducer, 'idForModel').returns(componentId);

    dummyProducer.subscribe(subscription);
    dummyProducer.produce.restore();

    sinon.stub(dummyProducer, 'produce', function () {
      assert(arguments[0][0] === componentId);
      done();
    });

    dummyProducer.onDiffInRepository(dummyProducer.repositories[0], {
      added: [],
      removed: [],
      changed: [
        {id: 'foo'}
      ]
    });
  });

  it('should not produce on added items that are not subscribed to', (done) => {
    const componentId = 1;

    sinon.stub(dummyProducer, 'produce', () => sinon.assert.fail());

    dummyProducer.onDiffInRepository(dummyProducer.repositories[0], {
      added: [],
      removed: [],
      changed: [
        {id: componentId}
      ]
    });

    setTimeout(done, 250);
  });


  it('should allow idForModel to return an array for removed items', (done) => {
    const componentId1 = 1;
    const componentId2 = 2;
    const subscription1 = {id: componentId1};
    const subscription2 = {id: componentId2};

    sinon.stub(dummyProducer, 'produce');
    sinon.stub(dummyProducer, 'idForModel').returns([componentId1, componentId2]);

    dummyProducer.subscribe(subscription1);
    dummyProducer.subscribe(subscription2);
    dummyProducer.produce.restore();

    sinon.stub(dummyProducer, 'produce', function(ids) {
      assert.deepEqual(ids, [componentId1, componentId2]);
      done();
    });

    dummyProducer.onDiffInRepository(dummyProducer.repositories[0], {
      added: [],
      removed: [],
      changed: [
        {id: 'foo'}
      ]
    });
  });


  it('should eventually produce on ids that were changed if shouldPropagateModelChange is true', (done) => {
    const componentId = 1;
    const subscription = {id: componentId};

    sinon.stub(dummyProducer, 'produce');
    sinon.stub(dummyProducer, 'shouldPropagateModelChange', () => true);

    dummyProducer.subscribe(subscription);
    dummyProducer.produce.restore();

    sinon.stub(dummyProducer, 'produce', function () {
      assert(arguments[0][0] === componentId);
      done();
    });

    dummyProducer.onDiffInRepository(dummyProducer.repositories[0], {
      added: [],
      removed: [],
      changed: [
        {id: subscription.id}
      ]
    });
  });


  it('should not produce on added items that are not subscribed to', (done) => {
    const componentId = 1;
    const subscription = {id: componentId};

    sinon.stub(dummyProducer, 'produce');
    sinon.stub(dummyProducer, 'shouldPropagateModelChange', () => false);

    dummyProducer.subscribe(subscription);
    dummyProducer.produce.restore();

    sinon.stub(dummyProducer, 'produce', () => sinon.assert.fail());

    dummyProducer.onDiffInRepository(dummyProducer.repositories[0], {
      added: [],
      removed: [],
      changed: [
        {id: componentId}
      ]
    });

    setTimeout(done, 250);
  });


  it('should eventually update given ids', (done) => {
    const componentId = 1;
    const subscription = {id: componentId};

    sinon.stub(dummyProducer, 'produce');

    dummyProducer.subscribe(subscription);
    dummyProducer.produce.restore();

    sinon.stub(dummyProducer, 'produce', function () {
      assert(arguments[0][0] === componentId);
      done();
    });

    dummyProducer.produceDataForIds([subscription.id]);
  });

  it('should eventually produce for all ids', (done) => {
    const componentId = 1;
    const subscription = {id: componentId};

    sinon.stub(dummyProducer, 'produce');

    dummyProducer.subscribe(subscription);
    dummyProducer.produce.restore();

    sinon.stub(dummyProducer, 'produce', function () {
      assert(arguments[0][0] === componentId);
      done();
    });

    dummyProducer.produceDataForIds();
  });


  it('should eventually produce for all ids when id type is string', (done) => {
    const componentId = 'hello';
    const subscription = {id: componentId};

    dummyProducer.idType = 'string';
    sinon.stub(dummyProducer, 'produce');

    dummyProducer.subscribe(subscription);
    dummyProducer.produce.restore();

    sinon.stub(dummyProducer, 'produce', function () {
      assert(arguments[0][0] === componentId);
      done();
    });

    dummyProducer.produceDataForIds();
  });

  it('calls currentData when producing data and add the passed id to the data returned', () => {
    const passedId = 1;
    const expectedResult = { id: 1 };
    const subscription = {id: passedId};
    const component = {
      options: subscription,
      callback: sinon.spy()
    };
    const fake = (id) => {
      assert(id === passedId);
      return {};
    };

    sinon.stub(dummyProducer, 'produce');
    dummyProducer.addComponent(component);

    dummyProducer.produce.restore();

    sinon.stub(dummyProducer, 'currentData', fake);
    dummyProducer.produce(dummyProducer.allIds());

    assert(component.callback.calledOnce);
    assert(component.callback.args.length === 1);
    assert(component.callback.args[0].length === 1);
    assert.deepEqual(component.callback.args[0][0], expectedResult);
  });

  it('if currentData doesnt return any data and empty object should be used', () => {
    const passedId = 1;
    const expectedResult = { id: 1 };
    const subscription = {id: passedId};
    const component = {
      options: subscription,
      callback: sinon.spy()
    };

    sinon.stub(dummyProducer, 'produce');

    dummyProducer.addComponent(component);
    dummyProducer.produce.restore();

    sinon.stub(dummyProducer, 'currentData', function(id) {
      assert(id === passedId);
      return undefined;
    });

    dummyProducer.produce(dummyProducer.allIds());

    assert(component.callback.calledOnce);
    assert(component.callback.args.length === 1);
    assert(component.callback.args[0].length === 1);
    assert.deepEqual(component.callback.args[0][0], expectedResult);
  });

  it('passes along data from currentData to decorate to allow gathered data to be decorated', () => {
    const passedId = 1;
    const expectedResult = {
      id: 1,
      val: 2,
      decoratedVal: 3
    };
    const subscription = {id: passedId};
    const component = {
      options: subscription,
      callback: sinon.spy()
    };

    sinon.stub(dummyProducer, 'produce');

    dummyProducer.addComponent(component);
    dummyProducer.produce.restore();

    sinon.stub(dummyProducer, 'currentData', function(id) {
      assert(id === passedId);
      return {val: 2};
    });

    const decorator1 = sinon.spy(data => data.decoratedVal = 3);

    dummyProducer.decorators = [decorator1];
    dummyProducer.produce(dummyProducer.allIds());

    assert(component.callback.calledOnce);
    assert(component.callback.args.length === 1);
    assert(component.callback.args[0].length === 1);
    assert.deepEqual(component.callback.args[0][0], expectedResult);
  });

  it('calls decorate when producing data', () => {
    const componentId = 1;
    const decoratedData = {};
    const subscription = {id: componentId};
    const component = {
      options: subscription,
      callback: sinon.spy()
    };

    sinon.stub(dummyProducer, 'produce');
    dummyProducer.addComponent(component);

    dummyProducer.produce.restore();
    sinon.stub(dummyProducer, 'decorate', (data) => {
      assert(data.id === componentId);
      return decoratedData;
    });

    dummyProducer.produce(dummyProducer.allIds());
    assert(component.callback.calledOnce);
    assert(component.callback.args.length === 1);
    assert(component.callback.args[0].length === 1);
    assert(component.callback.args[0][0] === decoratedData);
  });


  it('passes data through decorators in order before producing', () => {
    const componentId = 1;
    const decoratedData = {};
    const component = {
      options: {
        id: componentId
      },
      callback: sinon.spy()
    };

    sinon.stub(dummyProducer, 'produce');
    dummyProducer.addComponent(component);
    dummyProducer.produce.restore();

    const decorator1 = sinon.spy(data => data.decorator1 = true);
    const decorator2 = sinon.spy((data) => {
      assert.equal(data.decorator1, true);
      return data.decorator2 = true;
    });

    dummyProducer.decorators = [decorator1, decorator2];

    dummyProducer.produce(dummyProducer.allIds());

    assert(decorator1.calledOnce);
    assert(decorator2.calledOnce);

    assert(component.callback.calledOnce);
    assert(component.callback.args.length === 1);
    assert(component.callback.args[0].length === 1);
    assert(component.callback.args[0][0].decorator1);
    assert(component.callback.args[0][0].decorator2);
  });

  it('filters produced data to the component with the correct id', () => {
    const componentId1 = 1;
    const componentId2 = 2;
    const optionsId1 = 3;
    const optionsId2 = 4;
    const component1 = {
      id: componentId1,
      options: {
        id: optionsId1
      },
      callback: sinon.spy()
    };

    const component2 = {
      id: componentId2,
      options: {
        id: optionsId2
      },
      callback: sinon.spy()
    };

    sinon.stub(dummyProducer, 'produce');

    dummyProducer.addComponent(component1);
    dummyProducer.addComponent(component2);
    dummyProducer.produce.restore();

    dummyProducer.produce(dummyProducer.allIds());

    assert(component1.callback.args.length === 1);
    assert(component1.callback.args[0].length === 1);
    assert(component1.callback.args[0][0].id === optionsId1);

    assert(component2.callback.args.length === 1);
    assert(component2.callback.args[0].length === 1);
    assert(component2.callback.args[0][0].id === optionsId2);
  });

  it('should produce data to all components subscribed to the same options id', () => {
    const componentId1 = 1;
    const componentId2 = 2;
    const optionsId = 1;
    const component1 = {
      id: componentId1,
      options: {
        id: optionsId
      },
      callback: sinon.spy()
    };

    const component2 = {
      id: componentId2,
      options: {
        id: optionsId
      },
      callback: sinon.spy()
    };

    sinon.stub(dummyProducer, 'produce');

    dummyProducer.addComponent(component1);
    dummyProducer.addComponent(component2);
    dummyProducer.produce.restore();

    dummyProducer.produce(dummyProducer.allIds());
    assert(component1.callback.args.length === 1);
    assert(component1.callback.args[0].length === 1);
    assert(component1.callback.args[0][0].id === optionsId);

    assert(component2.callback.args.length === 1);
    assert(component2.callback.args[0].length === 1);
    assert(component2.callback.args[0][0].id === optionsId);
  });


  it('should not produce data to a component after it has been removed', () => {
    const componentId = 1;
    const optionsId = 1;


    const component = {
      id: componentId,
      options: {
        id: optionsId
      },
      callback: sinon.spy()
    };

    sinon.stub(dummyProducer, 'produce');

    dummyProducer.addComponent(component);
    dummyProducer.removeComponent(component.id);
    dummyProducer.produce.restore();

    dummyProducer.produce(dummyProducer.allIds());
    assert(component.callback.args.length === 0);
  });


  it('should continue to produce data to component after another component with the same options id is removed', () => {
    const componentId1 = 1;
    const componentId2 = 2;
    const optionsId = 1;


    const component1 = {
      id: componentId1,
      options: {
        id: optionsId
      },
      callback: sinon.spy()
    };

    const component2 = {
      id: componentId2,
      options: {
        id: optionsId
      },
      callback: sinon.spy()
    };
    sinon.stub(dummyProducer, 'produce');

    dummyProducer.addComponent(component1);
    dummyProducer.addComponent(component2);
    dummyProducer.removeComponent(component1.id);
    dummyProducer.produce.restore();

    dummyProducer.produce(dummyProducer.allIds());
    assert(component1.callback.args.length === 0);
    assert(component2.callback.args.length === 1);
  });
});
