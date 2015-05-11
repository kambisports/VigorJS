Vigor = require '../../../dist/vigor'
assert = require 'assert'
sinon = require 'sinon'

ComponentView = Vigor.ComponentView
ComponentViewModel = Vigor.ComponentViewModel

describe 'ComponentView', ->

  describe 'constructor', ->
    it 'should call _checkIfImplemented with an array containing mandatory methods', ->
      _checkIfImplemented = sinon.spy ComponentView.prototype, '_checkIfImplemented'
      view = new ComponentView()
      arr = [
        'renderStaticContent',
        'renderDynamicContent',
        'addSubscriptions',
        'removeSubscriptions',
        'dispose'
      ]

      assert _checkIfImplemented.calledWith arr
      _checkIfImplemented.restore()

    it 'should call super', ->
      parent = sinon.spy Backbone.View.prototype, 'constructor'
      view = new ComponentView()
      assert parent.called
      parent.restore()


  describe 'initialize', ->
    it 'should call super', ->
      parent = sinon.spy Backbone.View.prototype, 'initialize'
      view = new ComponentView()
      assert parent.called
      parent.restore()

    it 'should store viewModel as a property if passed', ->
      options =
        viewModel: new ComponentViewModel()

      view = new ComponentView options
      assert.equal view.viewModel, options.viewModel

    it 'should return this', ->
      view = new ComponentView()
      returnValue = view.initialize()
      assert.equal returnValue, view

  describe 'render', ->
    it 'should call renderStaticContent', ->
      view = new ComponentView()
      renderStaticContent = sinon.spy view, 'renderStaticContent'
      view.render()
      assert renderStaticContent.called
      renderStaticContent.restore()

    it 'should call addSubscriptions', ->
      view = new ComponentView()
      addSubscriptions = sinon.spy view, 'addSubscriptions'
      view.render()
      assert addSubscriptions.called
      addSubscriptions.restore()

    it 'should return this', ->
      view = new ComponentView()
      returnValue = view.render()
      assert.equal returnValue, view

  describe 'renderStaticContent', ->
    it 'should return this', ->
      view = new ComponentView()
      returnValue = view.renderStaticContent()
      assert.equal returnValue, view

  describe 'renderDynamicContent', ->
    it 'should return this', ->
      view = new ComponentView()
      returnValue = view.renderDynamicContent()
      assert.equal returnValue, view

  describe 'addSubscriptions', ->
    it 'should return this', ->
      view = new ComponentView()
      returnValue = view.addSubscriptions()
      assert.equal returnValue, view

  describe 'removeSubscriptions', ->
    it 'should return this', ->
      view = new ComponentView()
      returnValue = view.removeSubscriptions()
      assert.equal returnValue, view

  describe 'dispose', ->
    it 'should call unbind on this.model if it exists', ->
      model = new Backbone.Model()
      unbind = sinon.spy model, 'unbind'
      view = new ComponentView(model: model)
      do view.dispose
      assert unbind.called
      unbind.restore()

    it 'should call removeSubscriptions', ->
      view = new ComponentView()
      removeSubscriptions = sinon.spy view, 'removeSubscriptions'
      do view.dispose
      assert removeSubscriptions.called
      removeSubscriptions.restore()

    it 'should call stopListening', ->
      view = new ComponentView()
      stopListening = sinon.spy view, 'stopListening'
      do view.dispose
      assert stopListening.called
      stopListening.restore()

    it 'should call this.$el.off', ->
      view = new ComponentView()
      elOff = sinon.spy view.$el, 'off'
      do view.dispose
      assert elOff.called
      elOff.restore()

    it 'should call this.$el.remove', ->
      view = new ComponentView()
      elRemove = sinon.spy view.$el, 'remove'
      do view.dispose
      assert elRemove.called
      elRemove.restore()

    it 'should call this.off', ->
      view = new ComponentView()
      viewOff = sinon.spy view, 'off'
      do view.dispose
      assert viewOff.called
      viewOff.restore()

