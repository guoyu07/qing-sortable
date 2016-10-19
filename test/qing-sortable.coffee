QingSortable = require '../src/qing-sortable'
expect = chai.expect

describe 'QingSortable', ->

  $el = null
  qingSortable = null

  before ->
    $el = $('<div class="test-el"></div>').appendTo 'body'

  after ->
    $el.remove()
    $el = null

  beforeEach ->
    #qingSortable = new QingSortable
      #el: '.test-el'

  afterEach ->
    #qingSortable.destroy()
    #qingSortable = null

  #it 'should inherit from QingModule', ->
    #expect(qingSortable).to.be.instanceof QingModule
    #expect(qingSortable).to.be.instanceof QingSortable

  #it 'should throw error when element not found', ->
    #spy = sinon.spy QingSortable
    #try
      #new spy
        #el: '.not-exists'
    #catch e

    #expect(spy.calledWithNew()).to.be.true
    #expect(spy.threw()).to.be.true
