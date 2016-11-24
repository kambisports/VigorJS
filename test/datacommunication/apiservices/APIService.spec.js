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
      let fake = () => 'test';
      sinon.stub(apiService, 'channelForParams', fake);
      apiService.addSubscription({});
      assert.equal(_.keys(apiService.channels).length, 1);
      assert.ok(apiService.channels['test']);
    });

    it('creates multiple channels', () => {
      let params1 = {};
      let params2 = {};
      let fake = function(params) {
        switch (params) {
          case params1: return '1';
          case params2: return '2';
          default: return '';
        }
      };

      sinon.stub(apiService, 'channelForParams', fake);
      apiService.addSubscription({
        params: params1});

      apiService.addSubscription({
        params: params2});

      assert.equal(_.keys(apiService.channels).length, 2);
      assert.ok(apiService.channels['1']);
      assert.ok(apiService.channels['2']);
    });

    it('removes channels', () => {
      let subscription = {};

      sinon.stub(apiService, 'channelForParams', () => 'test');

      apiService.addSubscription(subscription);
      apiService.removeSubscription(subscription);

      assert.equal(_.keys(apiService.channels).length, 0);
    });

    it('removes channels by params reference', () => {
      let subscription1 = { };
      let subscription2 = { };
      let fake = () => 'test';

      sinon.stub(apiService, 'channelForParams', fake);

      apiService.addSubscription(subscription1);
      apiService.removeSubscription(subscription2);

      assert.equal(_.keys(apiService.channels).length, 1);
    });

    it('does not remove a channel if there is still a subscriber', () => {
      let subscription1 = {};
      let subscription2 = {};
      let fake = () => 'test';

      sinon.stub(apiService, 'channelForParams', fake);

      apiService.addSubscription(subscription1);
      apiService.addSubscription(subscription2);

      apiService.removeSubscription(subscription1);

      assert.equal(_.keys(apiService.channels).length, 1);
    });

    it('removes a channel even if other channels exist', () => {
      let subscription1 = {};
      let subscription2 = {};
      let fake = () => 'test';

      sinon.stub(apiService, 'channelForParams', fake);

      apiService.addSubscription(subscription1);
      apiService.addSubscription(subscription2);

      apiService.removeSubscription(subscription1);

      assert.equal(_.keys(apiService.channels).length, 1);
    });

    it('removes only the given channel', () => {
      let subscription1 = { params: { foo: 'bar' } };
      let subscription2 = { params: { foo: 'baz' } };
      let fake = params => params.foo;

      sinon.stub(apiService, 'channelForParams', fake);

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
      let spy = sinon.spy(apiService, 'channelForParams');

      let params = {};

      apiService.addSubscription({
        params});

      assert(spy.withArgs(params).calledOnce);
    });

    it('returns the stringified params by default', () => {
      let params =
        {foo: 'bar'};

      let channel = apiService.channelForParams(params);
      assert.equal(channel, JSON.stringify(params));
    });

    it('returns the stringified empty object for null params', () => {
      let channelForUndefined = apiService.channelForParams(undefined);
      let channelForEmpty = apiService.channelForParams({});

      assert.equal(channelForUndefined, channelForEmpty);
    });
  });

  describe('consolidates params', () => {
    it('is passed the a single param', () => {
      let spy = sinon.spy(apiService, 'consolidateParams');

      let params = {};

      apiService.addSubscription({
        params});

      assert(spy.calledOnce);

      let { args } = spy.lastCall;

      // args are params array, channel name
      assert.equal(args.length, 2);

      // check params
      assert.equal(args[0].length, 1);
      assert.equal(args[0][0], params);

      // channel name
      assert.equal(args[1], '{}');
    });


    it('is passed multiple params', () => {
      let spy = sinon.spy(apiService, 'consolidateParams');

      let params1 = {};
      let params2 = {};

      apiService.addSubscription({
        params: params1});

      apiService.addSubscription({
        params: params2});

      // one call for each time a subscription was added
      assert(spy.calledTwice);
      let { args } = spy.lastCall;

      // check params
      assert.equal(args[0].length, 2);
      assert.equal(args[0][0], params1);
      assert.equal(args[0][1], params2);
    });

    it('returns the first params by default', () => {
      let firstParams = {};
      let result = apiService.consolidateParams([firstParams, {}]);
      assert.equal(result, firstParams);
    });
  });

  describe('returns whether to fetch on params update', () => {
    it('returns true by default', () => {
      let shouldFetch = apiService.shouldFetchOnParamsUpdate();
      assert.ok(shouldFetch);
    });
  });

  describe('fetches data', () => {
    it('does one-off fetches', () => {
      let params = {};
      let fake = () => params;

      let consolidateParams = sinon.stub(apiService, 'consolidateParams', fake);
      let fetch = sinon.stub(apiService, 'fetch');

      apiService.addSubscription({
        params});

      assert(windowStub.setTimeout.calledOnce);
      let { args } = windowStub.setTimeout.lastCall;

      assert.equal(args.length, 2);
      assert.equal(args[1], 0);
      let callback = args[0];

      callback();

      assert(fetch.calledOnce);
      assert.equal(_.keys(apiService.services).length, 0);
    });

    it('does polled fetches', () => {
      let params = {};
      let pollingInterval = 100;
      let fake = () => params;

      let consolidateParams = sinon.stub(apiService, 'consolidateParams', fake);
      let fetch = sinon.stub(apiService, 'fetch');

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
      ({ args } = windowStub.setTimeout.lastCall);

      assert.equal(args.length, 2);
      assert.equal(args[1], pollingInterval);
      callback = args[0];

      callback();

      assert(fetch.calledTwice);
      assert.equal(_.keys(apiService.services).length, 0);
      assert(windowStub.setTimeout.calledThrice);
    });

    it('asks whether to fetch immediately when params change', () => {
      let params1 = {};
      let params2 = {};
      let pollingInterval = 100;
      let channelName = 'test';

      let consolidatedParams = [
        {
          foo: 'bar'
        },
        {
          baz: 'qux'
        }
      ];

      let fake = params => consolidatedParams[params.length - 1];

      let fake2 = () => channelName;
      // params must change
      let consolidateParams = sinon.stub(apiService, 'consolidateParams', fake);
      let channelForParams = sinon.stub(apiService, 'channelForParams', fake2);
      let fetch = sinon.stub(apiService, 'fetch');
      let shouldFetchOnParamsUpdate = sinon.stub(apiService, 'shouldFetchOnParamsUpdate');

      apiService.addSubscription({
        pollingInterval,
        params: params1
      });

      let callback = windowStub.setTimeout.lastCall.args[0];
      callback();

      apiService.addSubscription({
        pollingInterval,
        params: params2
      });

      assert(shouldFetchOnParamsUpdate.calledOnce);

      let { args } = apiService.shouldFetchOnParamsUpdate.lastCall;
      assert.ok(_.isEqual(args[0], consolidatedParams[1]));
      assert.ok(_.isEqual(args[1], consolidatedParams[0]));
      assert.equal(args[2], channelName);
    });

    it('fetches immediately when params change if shouldFetchOnParamsUpdate is true', () => {
      let params1 = {};
      let params2 = {};
      let pollingInterval = 100;
      let channelName = 'test';

      let consolidatedParams = [
        {
          foo: 'bar'
        },
        {
          baz: 'qux'
        }
      ];

      // params must change
      let fake = params => consolidatedParams[params.length - 1];

      let fake2 = () => channelName;

      let consolidateParams = sinon.stub(apiService, 'consolidateParams', fake);
      let channelForParams = sinon.stub(apiService, 'channelForParams', fake2);
      let fetch = sinon.stub(apiService, 'fetch');
      let shouldFetchOnParamsUpdate = sinon.stub(apiService, 'shouldFetchOnParamsUpdate', () => true);

      apiService.addSubscription({
        pollingInterval,
        params: params1
      });

      let callback = windowStub.setTimeout.lastCall.args[0];
      callback();

      apiService.addSubscription({
        pollingInterval,
        params: params2
      });

      let timeout = windowStub.setTimeout.lastCall.args[1];
      assert.equal(timeout, 0);
    });

    it('does not fetch immediately when params change if shouldFetchOnParamsUpdate is false', () => {
      let params1 = {};
      let params2 = {};
      let pollingInterval = 100;
      let channelName = 'test';

      let consolidatedParams = [
        {
          foo: 'bar'
        },
        {
          baz: 'qux'
        }
      ];

      let fake = params => consolidatedParams[params.length - 1];

      let fake2 = () => channelName;
      // params must change
      let consolidateParams = sinon.stub(apiService, 'consolidateParams', fake);
      let channelForParams = sinon.stub(apiService, 'channelForParams', () => fake2);
      let fetch = sinon.stub(apiService, 'fetch');
      let shouldFetchOnParamsUpdate = sinon.stub(apiService, 'shouldFetchOnParamsUpdate', () => false);

      apiService.addSubscription({
        pollingInterval,
        params: params1
      });


      let callback = windowStub.setTimeout.lastCall.args[0];
      callback();

      apiService.addSubscription({
        pollingInterval,
        params: params2
      });

      let timeout = windowStub.setTimeout.lastCall.args[1];
      assert.equal(timeout, 100);
    });

    it('does not ask to fetch immediately if params did not change', () => {
      let params1 = {};
      let params2 = {};
      let pollingInterval = 100;
      let channelName = 'test';

      let fake = params => ({});
      let fake2 = () => channelName;
      let fake3 =  () => false;
      let consolidatedParams = sinon.stub(apiService, 'consolidateParams', fake);
      let channelForParams = sinon.stub(apiService, 'channelForParams', fake2);
      let fetch = sinon.stub(apiService, 'fetch');
      let shouldFetchOnParamsUpdate = sinon.stub(apiService, 'shouldFetchOnParamsUpdate', fake3);

      apiService.addSubscription({
        pollingInterval,
        params: params1
      });


      let callback = windowStub.setTimeout.lastCall.args[0];
      callback();

      apiService.addSubscription({
        pollingInterval,
        params: params2
      });

      assert.equal(shouldFetchOnParamsUpdate.callCount, 0);
    });

    it('does not ask to fetch immediately if params change on different channels', () => {

      let params1 = {};
      let params2 = {};
      let pollingInterval = 100;
      let channelName = 'test';

      let fake = function(params) {
        switch (params[0]) {
          case params1: return { foo: 'bar' };
          case params2: return { baz: 'qux' };
          default: return {};
        }
      };

      let fake2 = function(params) {
        switch (params[0]) {
          case params1: return '1';
          case params2: return '2';
          default: return {};
        }
      };

      let consolidateParams = sinon.stub(apiService, 'consolidateParams', fake);
      let channelForParams = sinon.stub(apiService, 'channelForParams', fake2);
      let fetch = sinon.stub(apiService, 'fetch');
      let shouldFetchOnParamsUpdate = sinon.stub(apiService, 'shouldFetchOnParamsUpdate', () => false);

      apiService.addSubscription({
        pollingInterval,
        params: params1
      });

      let callback = windowStub.setTimeout.lastCall.args[0];
      callback();

      apiService.addSubscription({
        pollingInterval,
        params: params2
      },

        assert.equal(shouldFetchOnParamsUpdate.callCount, 0));
    });

    it('updates the polling interval to the most frequent rate', () => {

      let params1 = {};
      let params2 = {};
      let pollingInterval1 = 100;
      let pollingInterval2 = 50;

      let consolidateParams = sinon.stub(apiService, 'consolidateParams', () => params1);
      let channelForParams = sinon.stub(apiService, 'channelForParams', () => 'test');
      let fetch = sinon.stub(apiService, 'fetch');
      let shouldFetchOnParamsUpdate = sinon.stub(apiService, 'shouldFetchOnParamsUpdate', () => true);

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

      let timeout = windowStub.setTimeout.lastCall.args[1];
      assert.equal(timeout, 50);
    });

    it('does not update the polling interval if the new value is less frequent', () => {

      let params1 = {};
      let params2 = {};
      let pollingInterval1 = 50;
      let pollingInterval2 = 100;

      let fake = () => params1;
      let fake2 = () => 'test';

      let consolidateParams = sinon.stub(apiService, 'consolidateParams', fake);
      let channelForParams = sinon.stub(apiService, 'channelForParams', fake2);
      let fetch = sinon.stub(apiService, 'fetch');
      let shouldFetchOnParamsUpdate = sinon.stub(apiService, 'shouldFetchOnParamsUpdate', () => true);

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

      let params1 = {};
      let params2 = {};
      let pollingInterval1 = 100;
      let pollingInterval2 = 50;

      let elapsedTime = 20;
      let remainingTime = pollingInterval2 - elapsedTime;

      let fake = () => params1;
      let fake2 = () => 'test';

      let consolidateParams = sinon.stub(apiService, 'consolidateParams', fake);
      let channelForParams = sinon.stub(apiService, 'channelForParams', fake2);
      let fetch = sinon.stub(apiService, 'fetch');
      let shouldFetchOnParamsUpdate = sinon.stub(apiService, 'shouldFetchOnParamsUpdate', () => true);

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

      let timeout = windowStub.setTimeout.lastCall.args[1];
      assert.equal(timeout, remainingTime);
    });

    it('passes the correct remaining timeout when interval does not update', () => {

      let params1 = {};
      let params2 = {};
      let pollingInterval = 100;

      let remainingTime = pollingInterval;
      let fake = function(params) {
        switch (params[0]) {
          case params1: return { foo: 'bar' };
          case params2: return { baz: 'qux' };
          default: return {};
        }
      };

      let fake2 = () => 'test';
      let fake3 = () => true;

      let consolidateParams = sinon.stub(apiService, 'consolidateParams', fake);
      let channelForParams = sinon.stub(apiService, 'channelForParams', fake2);
      let fetch = sinon.stub(apiService, 'fetch');
      let shouldFetchOnParamsUpdate = sinon.stub(apiService, 'shouldFetchOnParamsUpdate', fake3);

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

      let timeout = windowStub.setTimeout.lastCall.args[1];
      assert.equal(timeout, remainingTime);
    });
  });

  describe('fetches data', () => {
    describe('default model', () => {
      it('syncs', () => {
        let model = new apiService.Model();
        let sync = sinon.stub(apiService, 'sync');

        let method = 'GET';
        model = model;
        let options = {};

        model.sync(method, model, options);

        assert.equal(sync.callCount, 1);
        let { args } = sync.lastCall;
        assert.equal(args.length, 3);
        assert.equal(args[0], method);
        assert.equal(args[1], model);
        assert.equal(args[2], options);
        assert.equal(sync.lastCall.thisValue, apiService);
      }
      );

      it('gets the URL', () => {
        let model = new apiService.Model();
        let url = sinon.stub(apiService, 'url');

        model.url();

        assert(url.calledOnce);
        let { args } = url.lastCall;
        assert.equal(args.length, 1);
        assert.equal(args[0], model);
        assert.equal(url.lastCall.thisValue, apiService);
      }
      );

      it('parses the response', () => {
        let model = new apiService.Model();
        let parse = sinon.stub(apiService, 'parse');

        let response = {};
        let options = {};
        model.parse(response, options);

        assert(parse.calledOnce);
        let { args } = parse.lastCall;
        assert.equal(args.length, 3);
        assert.equal(args[0], response);
        assert.equal(args[1], options);
        assert.equal(args[2], model);
        assert.equal(parse.lastCall.thisValue, apiService);
      }
      );

      it('can be overridden by getModelInstance', () => {
        let model = new Model();
        model.fetch = sinon.spy();

        apiService.getModelInstance = () => model;

        let consolidatedParams = {};

        apiService.onFetchSuccess = () => {};
        apiService.onFetchError = () => {};

        let callbacks = {
          success: apiService.onFetchSuccess,
          error: apiService.onFetchError
        };

        apiService.fetch(consolidatedParams);

        assert(model.fetch.calledOnce);

        let { args } = model.fetch.lastCall;
        assert.ok(_.isEqual(args[0], callbacks));
      }
      );
    });

    it('calls fetch on the service', () => {

      let consolidatedParams = {};
      let fake = () => consolidatedParams;

      let consolidateParams = sinon.stub(apiService, 'consolidateParams', fake);
      let fetch = sinon.stub(apiService, 'fetch');

      apiService.addSubscription({});

      let callback = windowStub.setTimeout.lastCall.args[0];
      callback();

      assert(fetch.calledOnce);

      let { args } = fetch.lastCall;
      assert.equal(args[0], consolidatedParams);
    });

    it('calls fetch on the model', () => {

      let consolidatedParams = {};

      let modelFetch = sinon.spy();

      let fake = function(params) {
        assert.equal(params, consolidatedParams);
        let model = new Model(params);
        model.fetch = modelFetch;
        return model;
      };

      let getModelInstance = sinon.stub(apiService, 'getModelInstance', fake);
      apiService.onFetchSuccess = () => {};
      apiService.onFetchError = () => {};

      let callbacks = {
        success: apiService.onFetchSuccess,
        error: apiService.onFetchError
      };

      apiService.fetch(consolidatedParams);

      assert(modelFetch.calledOnce);
      let { args } = modelFetch.lastCall;
      assert.ok(_.isEqual(args[0], callbacks));
    });
  });
});
