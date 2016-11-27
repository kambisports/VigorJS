import {APIService} from '../../../dist/vigor';
import {Model} from 'backbone';
import _ from 'underscore';
import assert from 'assert';
import sinon from 'sinon';

let apiService = undefined;
let windowStub = undefined;

class DateStub {
  constructor() {
    this.time = 0;
  }

  setNow(time) {
    this.time = time;
  }

  now() {
    return this.time;
  }
}

class WindowStub {
  constructor() {
    this.Date = new DateStub();
    this.setTimeout = sinon.spy();
    this.clearTimeout = sinon.spy();
  }
}

describe('An ApiService', () => {

  beforeEach(() => {
    windowStub = new WindowStub();
    apiService = new APIService(windowStub);
  });

  describe('handles subscriptions', () => {
    it('creates channels', () => {
      sinon.stub(apiService, 'channelForParams', () => 'test');
      apiService.addSubscription({});
      assert.equal(_.keys(apiService.channels).length, 1);
      assert.ok(apiService.channels['test']);
    });

    it('creates multiple channels', () => {
      const params1 = {};
      const params2 = {};

      sinon.stub(apiService, 'channelForParams', (params) => {
        switch (params) {
          case params1: return '1';
          case params2: return '2';
          default: return '';
        }
      });

      apiService.addSubscription({
        params: params1});

      apiService.addSubscription({
        params: params2});

      assert.equal(_.keys(apiService.channels).length, 2);
      assert.ok(apiService.channels['1']);
      assert.ok(apiService.channels['2']);
    });

    it('removes channels', () => {
      const subscription = {};

      sinon.stub(apiService, 'channelForParams', () => 'test');

      apiService.addSubscription(subscription);
      apiService.removeSubscription(subscription);

      assert.equal(_.keys(apiService.channels).length, 0);
    });

    it('removes channels by params reference', () => {
      const subscription1 = {};
      const subscription2 = {};

      sinon.stub(apiService, 'channelForParams', () => 'test');

      apiService.addSubscription(subscription1);
      apiService.removeSubscription(subscription2);

      assert.equal(_.keys(apiService.channels).length, 1);
    });

    it('does not remove a channel if there is still a subscriber', () => {
      const subscription1 = {};
      const subscription2 = {};

      sinon.stub(apiService, 'channelForParams', () => 'test');

      apiService.addSubscription(subscription1);
      apiService.addSubscription(subscription2);

      apiService.removeSubscription(subscription1);

      assert.equal(_.keys(apiService.channels).length, 1);
    });

    it('removes a channel even if other channels exist', () => {
      const subscription1 = {};
      const subscription2 = {};

      sinon.stub(apiService, 'channelForParams', () => 'test');

      apiService.addSubscription(subscription1);
      apiService.addSubscription(subscription2);

      apiService.removeSubscription(subscription1);

      assert.equal(_.keys(apiService.channels).length, 1);
    });

    it('removes only the given channel', () => {
      const subscription1 = { params: { foo: 'bar' } };
      const subscription2 = { params: { foo: 'baz' } };

      sinon.stub(apiService, 'channelForParams', params => params.foo);

      apiService.addSubscription(subscription1);
      apiService.addSubscription(subscription2);

      assert.equal(_.keys(apiService.channels).length, 2);

      apiService.removeSubscription(subscription1);

      assert.equal(_.keys(apiService.channels).length, 1);

      apiService.removeSubscription(subscription2);

      assert.equal(_.keys(apiService.channels).length, 0);
    });
  });


  describe('returns the channel for params', () => {
    it('is passed the params', () => {
      const spy = sinon.spy(apiService, 'channelForParams');
      const params = {};

      apiService.addSubscription({params});
      assert(spy.withArgs(params).calledOnce);
    });

    it('returns the stringified params by default', () => {
      const params = {foo: 'bar'};
      const channel = apiService.channelForParams(params);
      assert.equal(channel, JSON.stringify(params));
    });

    it('returns the stringified empty object for null params', () => {
      const channelForUndefined = apiService.channelForParams(undefined);
      const channelForEmpty = apiService.channelForParams({});
      assert.equal(channelForUndefined, channelForEmpty);
    });
  });

  describe('consolidates params', () => {
    it('is passed the a single param', () => {
      const spy = sinon.spy(apiService, 'consolidateParams');
      const params = {};

      apiService.addSubscription({params});
      assert(spy.calledOnce);

      const { args } = spy.lastCall;

      // args are params array, channel name
      assert.equal(args.length, 2);

      // check params
      assert.equal(args[0].length, 1);
      assert.equal(args[0][0], params);

      // channel name
      assert.equal(args[1], '{}');
    });


    it('is passed multiple params', () => {
      const spy = sinon.spy(apiService, 'consolidateParams');
      const params1 = {};
      const params2 = {};

      apiService.addSubscription({params: params1});
      apiService.addSubscription({params: params2});

      // one call for each time a subscription was added
      assert(spy.calledTwice);
      const { args } = spy.lastCall;

      // check params
      assert.equal(args[0].length, 2);
      assert.equal(args[0][0], params1);
      assert.equal(args[0][1], params2);
    });

    it('returns the first params by default', () => {
      const firstParams = {};
      const result = apiService.consolidateParams([firstParams, {}]);
      assert.equal(result, firstParams);
    });
  });

  describe('returns whether to fetch on params update', () => {
    it('returns true by default', () => {
      const shouldFetch = apiService.shouldFetchOnParamsUpdate();
      assert.ok(shouldFetch);
    });
  });

  describe('fetches data', () => {
    it('does one-off fetches', () => {
      const params = {};
      const consolidateParams = sinon.stub(apiService, 'consolidateParams', () => params);
      const fetch = sinon.stub(apiService, 'fetch');

      apiService.addSubscription({params});
      assert(windowStub.setTimeout.calledOnce);
      const { args } = windowStub.setTimeout.lastCall;

      assert.equal(args.length, 2);
      assert.equal(args[1], 0);
      const callback = args[0];

      callback();

      assert(fetch.calledOnce);
      assert.equal(_.keys(apiService.services).length, 0);
    });

    it('does polled fetches', () => {
      const params = {};
      const pollingInterval = 100;

      const consolidateParams = sinon.stub(apiService, 'consolidateParams', () => params);
      const fetch = sinon.stub(apiService, 'fetch');

      apiService.addSubscription({
        pollingInterval,
        params
      });

      assert(windowStub.setTimeout.calledOnce);
      let { args } = windowStub.setTimeout.lastCall;

      assert.equal(args.length, 2);
      assert.equal(args[1], 0);
      let callback = args[0];

      callback();

      assert(windowStub.setTimeout.calledTwice);
      args = windowStub.setTimeout.lastCall.args;

      assert.equal(args.length, 2);
      assert.equal(args[1], pollingInterval);
      callback = args[0];

      callback();

      assert(fetch.calledTwice);
      assert.equal(_.keys(apiService.services).length, 0);
      assert(windowStub.setTimeout.calledThrice);
    });

    it('asks whether to fetch immediately when params change', () => {
      const params1 = {};
      const params2 = {};
      const pollingInterval = 100;
      const channelName = 'test';

      const consolidatedParams = [
        {
          foo: 'bar'
        },
        {
          baz: 'qux'
        }
      ];

      // params must change
      const consolidateParams = sinon.stub(
        apiService,
        'consolidateParams',
        params => consolidatedParams[params.length - 1]
      );

      const channelForParams = sinon.stub(
        apiService,
        'channelForParams',
        () => channelName
      );

      const fetch = sinon.stub(apiService, 'fetch');
      const shouldFetchOnParamsUpdate = sinon.stub(apiService, 'shouldFetchOnParamsUpdate');

      apiService.addSubscription({
        pollingInterval,
        params: params1
      });

      const callback = windowStub.setTimeout.lastCall.args[0];
      callback();

      apiService.addSubscription({
        pollingInterval,
        params: params2
      });

      assert(shouldFetchOnParamsUpdate.calledOnce);

      const { args } = apiService.shouldFetchOnParamsUpdate.lastCall;
      assert.ok(_.isEqual(args[0], consolidatedParams[1]));
      assert.ok(_.isEqual(args[1], consolidatedParams[0]));
      assert.equal(args[2], channelName);
    });

    it('fetches immediately when params change if shouldFetchOnParamsUpdate is true', () => {
      const params1 = {};
      const params2 = {};
      const pollingInterval = 100;
      const channelName = 'test';

      const consolidatedParams = [
        {
          foo: 'bar'
        },
        {
          baz: 'qux'
        }
      ];

      // params must change
      const consolidateParams = sinon.stub(
        apiService,
        'consolidateParams',
        params => consolidatedParams[params.length - 1]
      );
      const channelForParams = sinon.stub(
        apiService,
        'channelForParams',
        () => channelName
      );
      const fetch = sinon.stub(apiService, 'fetch');
      const shouldFetchOnParamsUpdate = sinon.stub(apiService, 'shouldFetchOnParamsUpdate', () => true);

      apiService.addSubscription({
        pollingInterval,
        params: params1
      });

      const callback = windowStub.setTimeout.lastCall.args[0];
      callback();

      apiService.addSubscription({
        pollingInterval,
        params: params2
      });

      const timeout = windowStub.setTimeout.lastCall.args[1];
      assert.equal(timeout, 0);
    });

    it('does not fetch immediately when params change if shouldFetchOnParamsUpdate is false', () => {
      const params1 = {};
      const params2 = {};
      const pollingInterval = 100;
      const channelName = 'test';
      const consolidatedParams = [
        {
          foo: 'bar'
        },
        {
          baz: 'qux'
        }
      ];

      // params must change
      const consolidateParams = sinon.stub(
        apiService,
        'consolidateParams',
        params => consolidatedParams[params.length - 1]
      );

      const channelForParams = sinon.stub(
        apiService,
        'channelForParams',
        () => channelName
      );

      const fetch = sinon.stub(apiService, 'fetch');
      const shouldFetchOnParamsUpdate = sinon.stub(apiService, 'shouldFetchOnParamsUpdate', () => false);

      apiService.addSubscription({
        pollingInterval,
        params: params1
      });


      const callback = windowStub.setTimeout.lastCall.args[0];
      callback();

      apiService.addSubscription({
        pollingInterval,
        params: params2
      });

      const timeout = windowStub.setTimeout.lastCall.args[1];
      assert.equal(timeout, 100);
    });

    it('does not ask to fetch immediately if params did not change', () => {
      const params1 = {};
      const params2 = {};
      const pollingInterval = 100;
      const channelName = 'test';

      const consolidatedParams = sinon.stub(
        apiService,
        'consolidateParams',
        params => ({})
      );

      const channelForParams = sinon.stub(
        apiService,
        'channelForParams',
        () => channelName
      );

      const fetch = sinon.stub(
        apiService,
        'fetch'
      );

      const shouldFetchOnParamsUpdate = sinon.stub(
        apiService,
        'shouldFetchOnParamsUpdate',
        () => false
      );

      apiService.addSubscription({
        pollingInterval,
        params: params1
      });


      const callback = windowStub.setTimeout.lastCall.args[0];
      callback();

      apiService.addSubscription({
        pollingInterval,
        params: params2
      });

      assert.equal(shouldFetchOnParamsUpdate.callCount, 0);
    });

    it('does not ask to fetch immediately if params change on different channels', () => {

      const params1 = {};
      const params2 = {};
      const pollingInterval = 100;
      const channelName = 'test';

      const consolidateParams = sinon.stub(
        apiService,
        'consolidateParams',
        (params) => {
          switch (params[0]) {
            case params1: return { foo: 'bar' };
            case params2: return { baz: 'qux' };
            default: return {};
          }
        }
      );

      const channelForParams = sinon.stub(
        apiService,
        'channelForParams',
        (params) => {
          switch (params[0]) {
            case params1: return '1';
            case params2: return '2';
            default: return {};
          }
        }
      );

      const fetch = sinon.stub(apiService, 'fetch');
      const shouldFetchOnParamsUpdate = sinon.stub(
        apiService,
        'shouldFetchOnParamsUpdate',
        () => false
      );

      apiService.addSubscription({
        pollingInterval,
        params: params1
      });

      const callback = windowStub.setTimeout.lastCall.args[0];
      callback();

      apiService.addSubscription({
        pollingInterval,
        params: params2
      },

      assert.equal(shouldFetchOnParamsUpdate.callCount, 0));
    });

    it('updates the polling interval to the most frequent rate', () => {
      const params1 = {};
      const params2 = {};
      const pollingInterval1 = 100;
      const pollingInterval2 = 50;
      const consolidateParams = sinon.stub(
        apiService,
        'consolidateParams',
        () => params1
      );

      const channelForParams = sinon.stub(
        apiService,
        'channelForParams',
        () => 'test'
      );

      const fetch = sinon.stub(
        apiService,
       'fetch'
      );

      const shouldFetchOnParamsUpdate = sinon.stub(
        apiService,
        'shouldFetchOnParamsUpdate',
        () => true
      );

      apiService.addSubscription({
        pollingInterval: pollingInterval1,
        params: params1
      });

      let callback = windowStub.setTimeout.lastCall.args[0];
      callback();

      // the timeout for the first callback is always 0. Repetition sidesteps that case
      callback = windowStub.setTimeout.lastCall.args[0];
      callback();

      apiService.addSubscription({
        pollingInterval: pollingInterval2,
        params: params2
      });

      const timeout = windowStub.setTimeout.lastCall.args[1];
      assert.equal(timeout, 50);
    });

    it('does not update the polling interval if the new value is less frequent', () => {

      const params1 = {};
      const params2 = {};
      const pollingInterval1 = 50;
      const pollingInterval2 = 100;

      const consolidateParams = sinon.stub(
        apiService,
        'consolidateParams',
        () => params1
      );

      const channelForParams = sinon.stub(
        apiService,
        'channelForParams',
        () => 'test'
      );

      const fetch = sinon.stub(
        apiService,
        'fetch'
      );

      const shouldFetchOnParamsUpdate = sinon.stub(
        apiService,
        'shouldFetchOnParamsUpdate',
        () => true
      );


      apiService.addSubscription({
        pollingInterval: pollingInterval1,
        params: params1
      });

      let callback = windowStub.setTimeout.lastCall.args[0];
      callback();

      // the timeout for the first callback is always 0. Repetition sidesteps that case
      callback = windowStub.setTimeout.lastCall.args[0];
      callback();

      let timeout = windowStub.setTimeout.lastCall.args[1];
      assert.equal(timeout, 50);

      apiService.addSubscription({
        pollingInterval: pollingInterval2,
        params: params2
      });

      timeout = windowStub.setTimeout.lastCall.args[1];
      assert.equal(timeout, 50);
    });

    it('passes the correct remaining timeout when the polling interval changes', () => {
      const params1 = {};
      const params2 = {};
      const pollingInterval1 = 100;
      const pollingInterval2 = 50;
      const elapsedTime = 20;
      const remainingTime = pollingInterval2 - elapsedTime;

      const consolidateParams = sinon.stub(
        apiService,
        'consolidateParams',
        () => params1
      );

      const channelForParams = sinon.stub(
        apiService,
        'channelForParams',
        () => 'test'
      );

      const fetch = sinon.stub(
        apiService,
        'fetch'
      );

      const shouldFetchOnParamsUpdate = sinon.stub(
        apiService,
        'shouldFetchOnParamsUpdate',
        () => true
      );

      apiService.addSubscription({
        pollingInterval: pollingInterval1,
        params: params1
      });

      let callback = windowStub.setTimeout.lastCall.args[0];
      callback();

      // the timeout for the first callback is always 0. Repetition sidesteps that case
      callback = windowStub.setTimeout.lastCall.args[0];
      callback();

      windowStub.Date.setNow(20);

      apiService.addSubscription({
        pollingInterval: pollingInterval2,
        params: params2
      });

      const timeout = windowStub.setTimeout.lastCall.args[1];
      assert.equal(timeout, remainingTime);
    });

    it('passes the correct remaining timeout when interval does not update', () => {

      const params1 = {};
      const params2 = {};
      const pollingInterval = 100;

      const remainingTime = pollingInterval;

      const consolidateParams = sinon.stub(
        apiService,
        'consolidateParams',
        (params) => {
          switch (params[0]) {
            case params1: return { foo: 'bar' };
            case params2: return { baz: 'qux' };
            default: return {};
          }
        }
      );

      const channelForParams = sinon.stub(
        apiService,
        'channelForParams',
        () => 'test'
      );

      const fetch = sinon.stub(apiService, 'fetch');
      const shouldFetchOnParamsUpdate = sinon.stub(
        apiService,
        'shouldFetchOnParamsUpdate',
        () => true
      );

      apiService.addSubscription({
        pollingInterval,
        params: params1
      });

      let callback = windowStub.setTimeout.lastCall.args[0];
      callback();

      // the timeout for the first callback is always 0. Repetition sidesteps that case
      callback = windowStub.setTimeout.lastCall.args[0];
      callback();

      windowStub.Date.setNow(20);

      apiService.addSubscription({
        pollingInterval,
        params: params2
      });

      const timeout = windowStub.setTimeout.lastCall.args[1];
      assert.equal(timeout, remainingTime);
    });
  });

  describe('fetches data', () => {
    describe('default model', () => {
      it('syncs', () => {
        const model = new apiService.Model();
        const sync = sinon.stub(apiService, 'sync');
        const method = 'GET';
        const options = {};

        model.sync(method, model, options);

        assert.equal(sync.callCount, 1);
        const { args } = sync.lastCall;
        assert.equal(args.length, 3);
        assert.equal(args[0], method);
        assert.equal(args[1], model);
        assert.equal(args[2], options);
        assert.equal(sync.lastCall.thisValue, apiService);
      });

      it('gets the URL', () => {
        const model = new apiService.Model();
        const url = sinon.stub(apiService, 'url');

        model.url();

        assert(url.calledOnce);
        const { args } = url.lastCall;
        assert.equal(args.length, 1);
        assert.equal(args[0], model);
        assert.equal(url.lastCall.thisValue, apiService);
      });

      it('parses the response', () => {
        const model = new apiService.Model();
        const parse = sinon.stub(apiService, 'parse');

        const response = {};
        const options = {};
        model.parse(response, options);

        assert(parse.calledOnce);
        const { args } = parse.lastCall;
        assert.equal(args.length, 3);
        assert.equal(args[0], response);
        assert.equal(args[1], options);
        assert.equal(args[2], model);
        assert.equal(parse.lastCall.thisValue, apiService);
      });

      it('can be overridden by getModelInstance', () => {
        const model = new Model();
        model.fetch = sinon.spy();

        apiService.getModelInstance = () => model;

        const consolidatedParams = {};

        apiService.onFetchSuccess = () => {};
        apiService.onFetchError = () => {};

        const callbacks = {
          success: apiService.onFetchSuccess,
          error: apiService.onFetchError
        };

        apiService.fetch(consolidatedParams);

        assert(model.fetch.calledOnce);

        const { args } = model.fetch.lastCall;
        assert.ok(_.isEqual(args[0], callbacks));
      });
    });

    it('calls fetch on the service', () => {
      const consolidatedParams = {};
      const consolidateParams = sinon.stub(
        apiService,
        'consolidateParams',
        () => consolidatedParams
      );

      const fetch = sinon.stub(apiService, 'fetch');

      apiService.addSubscription({});

      const callback = windowStub.setTimeout.lastCall.args[0];
      callback();

      assert(fetch.calledOnce);

      const { args } = fetch.lastCall;
      assert.equal(args[0], consolidatedParams);
    });

    it('calls fetch on the model', () => {
      const consolidatedParams = {};
      const modelFetch = sinon.spy();
      const getModelInstance = sinon.stub(
        apiService,
        'getModelInstance',
        (params) => {
          assert.equal(params, consolidatedParams);
          const model = new Model(params);
          model.fetch = modelFetch;
          return model;
        }
      );
      apiService.onFetchSuccess = () => {};
      apiService.onFetchError = () => {};

      const callbacks = {
        success: apiService.onFetchSuccess,
        error: apiService.onFetchError
      };

      apiService.fetch(consolidatedParams);

      assert(modelFetch.calledOnce);
      const { args } = modelFetch.lastCall;
      assert.ok(_.isEqual(args[0], callbacks));
    });
  });
});
