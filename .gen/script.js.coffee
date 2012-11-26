$(window).load ->
  after = (ms, fn) -> setTimeout(fn, ms)

  demo    = $('.demo')
  arrow   = demo.find('.arrow')
  degrees = demo.find('.degrees span')

  Compass.noSupport ->
    after 400, ->
      demo.removeClass('init-step').addClass('disable')

  Compass.needGPS ->
    demo.removeClass('init-step').addClass('gps-step')

  Compass.needMove ->
    demo.removeClass('gps-step').addClass('move-step')

  Compass.init (method) ->
    if method
      demo.removeClass('init-step move-step').addClass('working')

  Compass.watch (heading) ->
    degrees.text(heading)
    arrow.css(transform: 'rotate(' + (-heading) + 'deg)')
