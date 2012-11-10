describe 'Compass', ->

  beforeEach ->
    Compass.method     = undefined
    Compass._initing   = false
    Compass._watchers  = { }
    Compass._nav       = { }
    Compass._win       =
      addEventListener:    sinon.spy()
      removeEventListener: sinon.spy()
    Compass._callbacks[i] = [] for i of Compass._callbacks
    Compass[i]?.restore?() for i of Compass

  describe '.watch()', ->

    it 'should use init()', ->
      Compass._initing = true
      Compass._nav.compass = { watchHeading: sinon.spy() }
      sinon.spy(Compass, 'init')

      Compass.watch( -> )

      Compass.init.should.have.been.called
      Compass._nav.compass.watchHeading.should.not.have.been.called

      Compass._start('phonegap')
      Compass._nav.compass.watchHeading.should.have.been.called

    it 'should generate new watcher ID', ->
      id1 = Compass.watch( -> )
      id2 = Compass.watch( -> )

      id1.should.not.eql(id2)

    it 'should watch for phonegap compass', ->
      Compass.method = 'phonegap'
      Compass._nav.compass = { watchHeading: sinon.stub().returns(3) }
      callback = ->

      id = Compass.watch(callback)

      Compass._nav.compass.watchHeading.should.have.been.calledWith(callback)
      Compass._watchers[id].should.eql(3)

    it 'should watch for webkitOrientation compass', ->
      Compass.method = 'webkitOrientation'
      callback = sinon.spy()

      id = Compass.watch(callback)

      Compass._watchers[id].should.be.a('function')
      Compass._win.addEventListener.should.have.been.
        calledWith('deviceorientation', Compass._watchers[id])

      callback.should.not.have.been.called
      Compass._watchers[id]({ webkitCompassHeading: 90 })
      callback.should.have.been.calledWith(90)

  describe '.unwatch()', ->

    it 'should delete watcher', ->
      Compass.method = 'supermethod'
      Compass._watchers[1] = 2

      Compass.unwatch(1)
      Compass._watchers.should.eql({ })

    it 'should remove phonegap watcher', ->
      Compass.method = 'phonegap'
      Compass._nav.compass = { clearWatch: sinon.spy() }
      Compass._watchers[1] = 3

      Compass.unwatch(1)

      Compass._nav.compass.clearWatch.should.have.been.calledWith(3)

    it 'should remove webkitOrientation watcher', ->
      Compass.method = 'webkitOrientation'
      callback = ->
      Compass._watchers[1] = callback

      Compass.unwatch(1)

      Compass._win.removeEventListener.should.have.been.
        calledWith('deviceorientation', callback)

  describe '.noSupport()', ->

    callback = null

    beforeEach ->
      callback = sinon.spy()

    it 'should save callback if method is not still detected', ->
      Compass.noSupport(callback)
      callback.should.not.have.been.called
      Compass._callbacks.noSupport.should.be.eql([callback])

    it 'execute callback if we detect, that there is no support', ->
      Compass.method = false
      Compass.noSupport(callback)
      callback.should.have.been.called
      Compass._callbacks.noSupport.should.be.empty

    it 'should forget callback if we can get compass', ->
      Compass.method = 'supermethod'
      Compass.noSupport(callback)
      callback.should.not.have.been.called
      Compass._callbacks.noSupport.should.be.empty

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
      Compass._callbacks.noSupport = [callback3]

      Compass._start('supermethod')

      callback1.should.have.been.calledWith('supermethod')
      callback2.should.have.been.calledWith('supermethod')
      Compass._callbacks.init.should.be.empty

      callback3.should.not.have.been.called
      Compass._callbacks.noSupport.should.be.empty

    it 'should execute noSupport callbacks if there is no method', ->
      callback1 = sinon.spy()
      callback2 = sinon.spy()
      Compass._callbacks.noSupport = [callback1, callback2]

      Compass._start(false)

      callback1.should.have.been.called
      callback2.should.have.been.called
      Compass._callbacks.noSupport.should.be.empty
