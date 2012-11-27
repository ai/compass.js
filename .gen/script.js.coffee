$(window).load ->
  after = (ms, fn) -> setTimeout(fn, ms)

  demo    = $('.demo')
  arrow   = demo.find('.arrow')
  degrees = demo.find('.degrees .value')

  Compass.noSupport ->
    after 400, ->
      demo.removeClass('init-step').addClass('disable')

  Compass.needGPS ->
    demo.removeClass('init-step').addClass('gps-step')

  Compass.needMove ->
    demo.removeClass('gps-step').addClass('move-step')

  Compass.init (method) ->
    if method != false and method != 'orientationAndGPS'
      demo.removeClass('animated').addClass('unanimated')
    if method
      demo.removeClass('init-step move-step').addClass('enable')

  Compass.watch (heading) ->
    degrees.text(Math.round(heading))
    arrow.css(transform: 'rotate(' + (-heading) + 'deg)')
