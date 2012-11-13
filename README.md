# Compass.js

Compass.js allow you to get compass heading in JavaScript.
Today there we haven’t any standard way to get compass data,
but there are two proprietary APIs and one hack:
* [PhoneGap have] `navigator.compass` API.
* iOS [Safari add] `webkitCompassHeading` property to `deviceorientation` event.
* We can enable GPS and ask user to go forward. GPS will send current heading,
  so we can calculate difference between real North and zero in
  `deviceorientation` event. Next we use this difference to get compass heading
  only by device orientation.

This library hide all this magic and APIs from you, autodetect available
way and provide clean and simple API for your geolocation web app.

Sponsored by [Evil Martians].

[PhoneGap have]: http://docs.phonegap.com/phonegap_compass_compass.md.html
[Safari add]:    http://developer.apple.com/library/safari/#documentation/SafariDOMAdditions/Reference/DeviceOrientationEventClassRef/DeviceOrientationEvent/DeviceOrientationEvent.html
[Evil Martians]: http://evilmartians.com/

## Usage

Simple way to use library is:

```js
Compass.watch(function (heading) {
  $('.degrees').text(heading);
  $('.compass').css({ transform: 'rotate(' + (-heading) + 'deg)' });
});
```

### Messages

If you develop not just for iTunes or Google Play with PhoneGap,
you need to think about desktop browsers and GPS hack.

You must add this event listeners **before** `Compass.watch`.

For desktop users (without GPS and accelerometers) we hide compass:

```js
Compass.noSupport(function () {
  $('.compass').hide();
});
```

For Android users (and another devices, where we will use GPS hack)
we need to show help instructions:

```js
// Step 1. We need to good GPS signal.
Compass.needGPS(function () {
  $('.go-outside-message').show();
});

// Step 2. User must go forward.
Compass.needMove(function () {
  $('.go-outside-message').hide()
  $('.move-and-hold-ahead-message').show();
});

// GPS hack is enabled. Hide all messages.
Compass.init(function () {
  $('.move-and-hold-ahead-message').hide();
});
```

### Compass Method

Library will detect method asyncronly, so you can’t just check
`Compass.method`, because it can be empty yet. It will be better to
use `Compass.init` method:

```js
Compass.init(function (method) {
  console.log('Compass heading by ' + method);
});
```

Callback will be execute also if library is already initialized.

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
Take it from: [github.com/ai/compass.js/downloads].

[github.com/ai/compass.js/downloads]: https://github.com/ai/compass.js/downloads

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
