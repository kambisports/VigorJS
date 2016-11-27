import {ComponentBase} from '../../dist/vigor';
import assert from 'assert';
import sinon from 'sinon';

describe('ComponentBase', () => {
  describe('render', () => {
    it('should throw an error if not over-riden', () => {
      const component = new ComponentBase();
      const errorFn = () => component.render();
      assert.throws((() => errorFn()), /ComponentBase->render needs to be over-ridden/);
    });
  });

  describe('dispose', () => {
    it('should throw an error if not over-riden', () => {
      const component = new ComponentBase();
      const errorFn = () => component.dispose();
      assert.throws((() => errorFn()), /ComponentBase->dispose needs to be over-ridden/);
    });
  });
});

