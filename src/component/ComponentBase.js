import _ from 'underscore';
import {Events, Model} from 'backbone';
// ##ComponentBase
// This class is intended to be the public interface for a component.
//
// By default it exposes a render and a dispose method which should be overridden
//
// To create a component you would typically do a index file which extends ComponentBase
// and then instantiate any views, models, collections etc. that the component need
// within the index file.

class ComponentBase {
  // ComponentBase.extend = Backbone.Model.extend;
  // Add Vigor.extend (Backbone.Model.extend) <br/>
  // [Backbone.Model.extend](http://backbonejs.org/#Model-extend)
  static get extend() {
    return Model.extend;
  }
  // **render:** <br/>
  // Override this method
  render() {
    throw 'ComponentBase->render needs to be over-ridden';
  }

  // **dispose:** <br/>
  // Override this method
  dispose() {
    throw 'ComponentBase->dispose needs to be over-ridden';
  }
}

// Extends Backbone.Events <br/>
// [Backbone.Events](http://backbonejs.org/#Events)
_.extend(ComponentBase.prototype, Events);

export default ComponentBase;

