# Compass.js

Compass.js allows you to get compass heading in JavaScript.
Today we haven’t any standard way to get compass data,
but there are two proprietary APIs and one hack:

* [PhoneGap has] `navigator.compass` API.
* iOS [Safari adds] `webkitCompassHeading` property to `deviceorientation` event.
* We can enable GPS and ask user to go forward. GPS will send current heading,
  so we can calculate difference between real North and zero in
  `deviceorientation` event. Next we use this difference to get compass heading
  only by device orientation.

This library hides all this magic and APIs from you, autodetects available
way and provides clean and simple API for your geolocation web app.

Sponsored by [Evil Martians].

[PhoneGap has]:  http://docs.phonegap.com/phonegap_compass_compass.md.html
[Safari adds]:   http://developer.apple.com/library/safari/#documentation/SafariDOMAdditions/Reference/DeviceOrientationEventClassRef/DeviceOrientationEvent/DeviceOrientationEvent.html
[Evil Martians]: http://evilmartians.com/

## Usage


Hide compass for desktop users (without compass, GPS and accelerometers):

```js
Compass.noSupport(function () {
  $('.compass').hide();
});
```

Show instructions for Android users:

```js
Compass.needGPS(function () {
  $('.go-outside-message').show();          // Step 1: we need GPS signal
}).needMove(function () {
  $('.go-outside-message').hide()
  $('.move-and-hold-ahead-message').show(); // Step 2: user must go forward
}).init(function () {
  $('.move-and-hold-ahead-message').hide(); // GPS hack is enabled
});
```

Add compass heading listener:

```js
Compass.watch(function (heading) {
  $('.degrees').text(heading);
  $('.compass').css({ transform: 'rotate(' + (-heading) + 'deg)' });
});
```

### Method Name

Library will detect method asynchronously, so you can’t just read
`Compass.method`, because it can be empty yet. It will be better to
use `Compass.init` method:

```js
Compass.init(function (method) {
  console.log('Compass heading by ' + method);
});
```

If library is already initialized, callback will be executed instantly,
without reinitialization.

### Unwatch

You can remove compass listener by `Compass.unwatch` method:

```js
var watchID = Compass.watch(function (heading) {
  $('.degrees').text(heading);
});

Compass.unwatch(watchID);
```

## Installing

### Ruby on Rails

For Ruby on Rails you can use gem for Assets Pipeline.

1. Add `compassjs` gem to `Gemfile`:

   ```ruby
   gem "compassjs"
   ```

2. Install gems:

   ```sh
   bundle install
   ```

3. Include Pages.js to your `application.js.coffee`:

   ```coffee
   #= require compass
   ```

### Others

If you don’t use any assets packaging manager (it’s very bad idea), you can use
already minified version of the library.

Take it from: [ai.github.com/compass.js/compass.js].

[ai.github.com/compass.js/compass.js]: http://ai.github.com/compass.js/compass.js

## Contributing

1. To run tests you need node.js and npm. For example, in Ubuntu run:

   ```sh
   sudo apt-get install nodejs npm
   ```

2. Next install npm dependencies:

   ```sh
   npm install
   ```

3. Run all tests:

   ```sh
   ./node_modules/.bin/cake test
   ```

4. Run test server:

   ```sh
   ./node_modules/.bin/cake server
   ```

5. Open tests in browser: [localhost:8000].
6. Also you can see real usage example in integration test:
   [localhost:8000/integration].

[localhost:8000]: http://localhost:8000
[localhost:8000/integration]: http://localhost:8000/integration
