describe 'Compass', ->

  beforeEach ->
    Compass.method    = undefined
    Compass._initing  = false
    Compass._watchers = { }
    Compass._gpsDiff  = undefined
    Compass._checking = false

    Compass._win =
      addEventListener:    sinon.spy()
      removeEventListener: sinon.spy()
    Compass._nav =
      geolocation:
        watchPosition: sinon.spy()
        clearWatch:    sinon.spy()

    Compass._callbacks[i] = [] for i of Compass._callbacks
    Compass[i]?.restore?() for i of Compass

  afterEach ->
    @clock?.restore()

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

    it 'should watch for orientationAndGPS compass', ->
      Compass.method   = 'orientationAndGPS'
      Compass._gpsDiff = 10
      callback = sinon.spy()

      id = Compass.watch(callback)

      Compass._watchers[id].should.be.a('function')
      Compass._win.addEventListener.should.have.been.
        calledWith('deviceorientation', Compass._watchers[id])

      callback.should.not.have.been.called
      Compass._watchers[id]({ alpha: 90 })
      callback.should.have.been.calledWith(280)

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

    it 'should remove orientationAndGPS watcher', ->
      Compass.method = 'orientationAndGPS'
      callback = ->
      Compass._watchers[1] = callback

      Compass.unwatch(1)

      Compass._win.removeEventListener.should.have.been.
        calledWith('deviceorientation', callback)

    it 'should return Compass', ->
      Compass.unwatch(1).should.eql(Compass)

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

    it 'should return Compass', ->
      Compass.noSupport( -> ).should.eql(Compass)

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
      @clock = sinon.useFakeTimers()
      Compass._win.DeviceOrientationEvent = ->
      Compass.init(callback)
      Compass._win.addEventListener.should.have.been.
        calledWith('deviceorientation', Compass._checkEvent)

      Compass._checkEvent({ alpha: null })
      Compass._start.should.not.have.been.calledWith(false)

      @clock.tick(1000)
      Compass._start.should.have.been.calledWith(false)

    it 'should start GPS hack with orientation and geolocation', ->
      @clock = sinon.useFakeTimers()
      Compass._win.DeviceOrientationEvent = ->
      sinon.stub(Compass, '_gpsHack');

      Compass.init(callback)

      Compass._checkEvent({ alpha: 10 })
      Compass._start.should.have.not.been.calledWith(false)
      Compass._gpsHack.should.have.been.called

      @clock.tick(1000)
      Compass._start.should.have.not.been.called

    it 'should use 2 orientation check', ->
      @clock = sinon.useFakeTimers()
      Compass._win.DeviceOrientationEvent = ->
      sinon.stub(Compass, '_gpsHack');

      Compass.init(callback)

      Compass._checkEvent({ alpha: null })
      Compass._start.should.have.not.been.calledWith(false)
      Compass._gpsHack.should.not.have.been.called

      Compass._checkEvent({ alpha: 10 })
      Compass._start.should.have.not.been.calledWith(false)
      Compass._gpsHack.should.have.been.called

    it 'should have timeout for orientation event', ->
      @clock = sinon.useFakeTimers()

      Compass._win.DeviceOrientationEvent = ->
      Compass.init(callback)
      Compass._start.should.not.have.been.calledWith(false)

      @clock.tick(1000)
      Compass._start.should.have.been.calledWith(false)

    it 'should return Compass', ->
      Compass.init( -> ).should.eql(Compass)

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

  describe '._gpsHack()', ->

    it 'should detect no support on geolocation error', ->
      Compass._nav.geolocation.watchPosition = (success, error) -> error()
      sinon.stub(Compass, '_start')

      Compass._gpsHack()

      Compass._start.should.have.been.calledWith(false)
      Compass._win.removeEventListener.should.have.been.called

    it 'should detect _gpsDiff', ->
      geolocation = null
      orientation = null

      Compass._nav.geolocation.watchPosition = (c) -> geolocation = c
      sinon.spy(Compass._nav.geolocation, 'watchPosition')

      Compass._win.addEventListener = (n, c) -> orientation = c
      sinon.spy(Compass._win, 'addEventListener')

      needGPS  = sinon.spy()
      needMove = sinon.spy()
      Compass.needGPS(needGPS).should.eql(Compass)
      Compass.needMove(needMove).should.eql(Compass)
      sinon.stub(Compass, '_start')

      Compass._gpsHack()

      orientation.should.be.a('function')
      Compass._win.addEventListener.should.have.been.
        calledWith('deviceorientation', orientation)

      geolocation.should.be.a('function')
      Compass._nav.geolocation.watchPosition.should.have.been.
        calledWith(geolocation, sinon.match.func, { enableHighAccuracy: true })

      needGPS.should.have.been.called
      needMove.should.not.have.been.called

      geolocation(coords: { speed: null, heading: null })
      needMove.should.not.have.been.called

      geolocation(coords: { speed: 0, heading: 0 })
      needMove.should.have.been.called

      geolocation(coords: { speed: 2, heading: 0 })
      needMove.should.have.been.calledOnce
      Compass._start.should.not.have.been.called

      orientation(alpha: 10)
      geolocation(coords: { speed: 2, heading: 0 })
      Compass._start.should.not.have.been.calledWith('orientationAndGPS')

      geolocation(coords: { speed: 0, heading: 0 })

      orientation(alpha: 10)
      orientation(alpha: 15)
      orientation(alpha: 20)
      orientation(alpha: 20)
      geolocation(coords: { speed: 2, heading: 0 })
      geolocation(coords: { speed: 2, heading: 0 })
      geolocation(coords: { speed: 2, heading: 5 })
      geolocation(coords: { speed: 2, heading: 10 })
      Compass._start.should.not.have.been.calledWith('orientationAndGPS')

      geolocation(coords: { speed: 2, heading: 10 })
      Compass._start.should.have.been.calledWith('orientationAndGPS')
      Compass._gpsDiff.should.eql(20)
