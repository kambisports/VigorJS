Vigor = require '../../../dist/vigor'
assert = require 'assert'
sinon = require 'sinon'

ComponentBase = Vigor.ComponentBase

describe 'ComponentBase', ->

  describe 'render', ->
    it 'should throw an error if not over-riden', ->
      component = new ComponentBase()
      errorFn = -> component.render()
      assert.throws (-> errorFn()), /ComponentBase->render needs to be over-ridden/

  describe 'dispose', ->
    it 'should throw an error if not over-riden', ->
      component = new ComponentBase()
      errorFn = -> component.dispose()
      assert.throws (-> errorFn()), /ComponentBase->dispose needs to be over-ridden/

