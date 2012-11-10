describe 'Compass', ->

  beforeEach ->
    Compass.method     = undefined
    Compass._initing   = false
    Compass._nav       = { }
    Compass._win       =
      addEventListener:    sinon.spy()
      removeEventListener: sinon.spy()
    Compass._callbacks[i] = [] for i of Compass._callbacks
    Compass[i]?.restore?() for i of Compass

  describe '.nosupport()', ->

    callback = null

    beforeEach ->
      callback = sinon.spy()

    it 'should save callback if method is not still detected', ->
      Compass.nosupport(callback)
      callback.should.not.have.been.called
      Compass._callbacks.nosupport.should.be.eql([callback])

    it 'execute callback if we detect, that there is no support', ->
      Compass.method = false
      Compass.nosupport(callback)
      callback.should.have.been.called
      Compass._callbacks.nosupport.should.be.empty

    it 'should forget callback if we can get compass', ->
      Compass.method = 'supermethod'
      Compass.nosupport(callback)
      callback.should.not.have.been.called
      Compass._callbacks.nosupport.should.be.empty

  describe '.init()', ->

    callback = null

    beforeEach ->
      sinon.stub(Compass, '_start')
      callback = sinon.spy()

    it 'should execute callback if method already detected', ->
      Compass.method = 'supermethod'

      Compass.init(callback)

      callback.should.have.been.calledWith('supermethod')
      Compass._callbacks.init.should.be.empty
      Compass._initing.should.be.false

    it 'should add listener and set initing', ->
      Compass.init(callback)

      Compass._initing.should.be.true
      Compass._callbacks.init.should.eql([callback])

    it 'should detect no support', ->
      Compass.init(callback)
      Compass._start.should.have.been.calledWith(false)

    it 'should not initialize twice', ->
      Compass._initing = true

      Compass.init(callback)

      Compass._callbacks.init.should.eql([callback])
      Compass._start.should.have.not.been.calledWith(false)

    it 'should detect phonegap support', ->
      Compass._nav.compass = { watchHeading: -> }
      Compass.init(callback)
      Compass._start.should.have.been.calledWith('phonegap')

    it 'should detect webkitOrientation support', ->
      Compass._win.DeviceOrientationEvent = ->
      Compass.init(callback)
      Compass._win.addEventListener.should.have.been.
        calledWith('deviceorientation', Compass._checkEvent)

      Compass._checkEvent({ webkitCompassHeading: -> })
      Compass._start.should.have.been.calledWith('webkitOrientation')
      Compass._win.removeEventListener.should.have.been.
        calledWith('deviceorientation', Compass._checkEvent)

    it 'should detect no support in orientation event', ->
      Compass._win.DeviceOrientationEvent = ->
      Compass.init(callback)
      Compass._win.addEventListener.should.have.been.
        calledWith('deviceorientation', Compass._checkEvent)

      Compass._checkEvent({ })
      Compass._start.should.have.been.calledWith(false)
      Compass._win.removeEventListener.should.have.been.
        calledWith('deviceorientation', Compass._checkEvent)

  describe '._start()', ->

    it 'should set state variables', ->
      Compass._initing = true
      Compass._start('supermethod')

      Compass.method.should.eql('supermethod')
      Compass._initing.should.be.false

    it 'should execute all init callbacks with method', ->
      callback1 = sinon.spy()
      callback2 = sinon.spy()
      callback3 = sinon.spy()
      Compass._callbacks.init      = [callback1, callback2]
      Compass._callbacks.nosupport = [callback3]

      Compass._start('supermethod')

      callback1.should.have.been.calledWith('supermethod')
      callback2.should.have.been.calledWith('supermethod')
      Compass._callbacks.init.should.be.empty

      callback3.should.not.have.been.called
      Compass._callbacks.nosupport.should.be.empty

    it 'should execute nosupport callbacks if there is no method', ->
      callback1 = sinon.spy()
      callback2 = sinon.spy()
      Compass._callbacks.nosupport = [callback1, callback2]

      Compass._start(false)

      callback1.should.have.been.called
      callback2.should.have.been.called
      Compass._callbacks.nosupport.should.be.empty
