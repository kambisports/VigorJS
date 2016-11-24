import {View, Model} from 'backbone';
import {ComponentView, ComponentViewModel} from '../../dist/vigor';
import assert from 'assert';
import sinon from 'sinon';

describe('ComponentView', () => {
  describe('constructor', () => {
    it('should call _checkIfImplemented with an array containing mandatory methods', () => {
      const _checkIfImplemented = sinon.spy(ComponentView.prototype, '_checkIfImplemented');
      const view = new ComponentView();
      const arr = [
        'renderStaticContent',
        'renderDynamicContent',
        'addSubscriptions',
        'removeSubscriptions',
        'dispose'
      ];

      assert(_checkIfImplemented.calledWith(arr));
      _checkIfImplemented.restore();
    });
  });

  describe('initialize', () => {
    it('should call super', () => {
      const parent = sinon.spy(View.prototype, 'initialize');
      const view = new ComponentView();
      assert(parent.called);
      parent.restore();
    });

    it('should store viewModel as a property if passed', () => {
      const options = {
        viewModel: new ComponentViewModel()
      };
      const view = new ComponentView(options);
      assert.equal(view.viewModel, options.viewModel);
    });

    it('should return this', () => {
      const view = new ComponentView();
      const returnValue = view.initialize();
      assert.equal(returnValue, view);
    });
  });

  describe('render', () => {
    it('should call renderStaticContent', () => {
      const view = new ComponentView();
      const renderStaticContent = sinon.spy(view, 'renderStaticContent');
      view.render();
      assert(renderStaticContent.called);
      renderStaticContent.restore();
    });

    it('should call addSubscriptions', () => {
      const view = new ComponentView();
      const addSubscriptions = sinon.spy(view, 'addSubscriptions');
      view.render();
      assert(addSubscriptions.called);
      addSubscriptions.restore();
    });

    it('should return this', () => {
      const view = new ComponentView();
      const returnValue = view.render();
      assert.equal(returnValue, view);
    });
  });

  describe('renderStaticContent', () => {
    it('should return this', () => {
      const view = new ComponentView();
      const returnValue = view.renderStaticContent();
      assert.equal(returnValue, view);
    });
  });

  describe('renderDynamicContent', () => {
    it('should return this', () => {
      const view = new ComponentView();
      const returnValue = view.renderDynamicContent();
      assert.equal(returnValue, view);
    })
  });

  describe('addSubscriptions', () => {
    it('should return this', () => {
      const view = new ComponentView();
      const returnValue = view.addSubscriptions();
      assert.equal(returnValue, view);
    })
  });

  describe('removeSubscriptions', () => {
    it('should return this', () => {
      const view = new ComponentView();
      const returnValue = view.removeSubscriptions();
      assert.equal(returnValue, view);
    });
  });

  describe('dispose', () => {
    it('should call unbind on this.model if it exists', () => {
      const model = new Model();
      const unbind = sinon.spy(model, 'unbind');
      const view = new ComponentView({model});
      view.dispose();
      assert(unbind.called);
      unbind.restore();
    });

    it('should call removeSubscriptions', () => {
      const view = new ComponentView();
      const removeSubscriptions = sinon.spy(view, 'removeSubscriptions');
      view.dispose();
      assert(removeSubscriptions.called);
      removeSubscriptions.restore();
    });

    it('should call stopListening', () => {
      const view = new ComponentView();
      const stopListening = sinon.spy(view, 'stopListening');
      view.dispose();
      assert(stopListening.called);
      stopListening.restore();
    });

    it('should call this.$el.off', () => {
      const view = new ComponentView();
      const elOff = sinon.spy(view.$el, 'off');
      view.dispose();
      assert(elOff.called);
      elOff.restore();
    });

    it('should call this.$el.remove', () => {
      const view = new ComponentView();
      const elRemove = sinon.spy(view.$el, 'remove');
      view.dispose();
      assert(elRemove.called);
      elRemove.restore();
    });

    it('should call this.off', () => {
      const view = new ComponentView();
      const viewOff = sinon.spy(view, 'off');
      view.dispose();
      assert(viewOff.called);
      viewOff.restore();
    });
  });
});

