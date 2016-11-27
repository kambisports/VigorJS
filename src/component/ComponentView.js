import {View} from 'backbone';
// ##ComponentView
// This class is intended to be used as a base class for all views within a component
// It enforces five methods to unify the structure of ComponentViews accross a large application:
//
// - renderStaticContent
// - renderDynamicContent
// - addSubscriptions
// - removeSubscriptions
// - dispose
//

class ComponentView extends View {

  // **constructor** <br/>
  constructor(options) {
    super(options);
    // These methods are required to make our view code
    // structure more consistent (just make them empty if
    // you don't need them).
    this._checkIfImplemented([
      'renderStaticContent',
      'renderDynamicContent',
      'addSubscriptions',
      'removeSubscriptions',
      'dispose'
    ]);

  }

  // **initialize** <br/>
  // @param object <br/>
  // @return this: Object <br/>
  // view options, usually containing a viewModel instance <br/>
  initialize(options) {
    if (options && options.viewModel) {
      this.viewModel = options.viewModel;
    }
    super.initialize(...arguments);
    return this;
  }

  // **render** <br/>
  // @return this: Object <br/>
  // the views render method, it will call @renderStaticContent and @addSubscriptions <br/>
  render() {
    this.renderStaticContent();
    this.addSubscriptions();
    return this;
  }

  // **renderStaticContent** <br/>
  // @return this: Object <br/>
  // Override this. <br/>
  // Render parts of component that don't rely on model. <br/>
  renderStaticContent() {
    return this;
  }

  // **renderDynamicContent** <br/>
  // @return this: Object <br/>
  // Override this. <br/>
  // Render parts of component that relies on model. <br/>
  renderDynamicContent() {
    return this;
  }

  // **addSubscriptions** <br/>
  // @return this: Object <br/>
  // Override this. <br/>
  // Add view model subscriptions if needed. <br/>
  addSubscriptions() {
    return this;
  }

  // **removeSubscriptions** <br/>
  // @return this: Object <br/>
  // Override this. <br/>
  // Remove view model subscriptions.
  removeSubscriptions() {
    return this;
  }

  // **dispose** <br/>
  // Removes events and dom elements related to the view <br/>
  // Override this, and call super.
  dispose() {
    if (this.model) {
      this.model.unbind()
    }
    this.removeSubscriptions();
    this.stopListening();
    this.$el.off();
    this.$el.remove();
    return this.off();
  }

  // **_checkIfImplemented** <br/>
  // @param array: Array <br/>
  // Ensures that passed methods are implemented in the view
  _checkIfImplemented(methodNames) {
    return (() => {
      let result = [];
      for (let i = 0; i < methodNames.length; i++) {
        let methodName = methodNames[i];
        let item;
        if (!this.constructor.prototype.hasOwnProperty(methodName)) {
          throw new Error(`${this.constructor.name} - ${methodName}() must be implemented in View.`);
        }
        result.push(item);
      }
      return result;
    })();
  }
}

export default ComponentView;
