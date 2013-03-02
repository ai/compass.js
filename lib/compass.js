/*
 * Copyright 2012 Andrey “A.I.” Sitnik <andrey@sitnik.ru>,
 * sponsored by Evil Martians.
 *
 * This program is free software: you can redistribute it and/or modify
 * it under the terms of the GNU Lesser General Public License as published by
 * the Free Software Foundation, either version 3 of the License, or
 * (at your option) any later version.
 *
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU Lesser General Public License for more details.
 *
 * You should have received a copy of the GNU Lesser General Public License
 * along with this program.  If not, see <http://www.gnu.org/licenses/>.
 */

;(function(undefined) {
  "use strict";

  // Shortcut to check, that `variable` is not `undefined` or `null`.
  var defined = function (variable) {
    return (variable != null || variable != undefined);
  };

  // Fire `type` callbacks with `args`.
  var fire = function (type, args) {
    var callbacks = self._callbacks[type];
    for (var i = 0; i < callbacks.length; i++) {
      callbacks[i].apply(window, args);
    }
  };

  // Calculate average value for last 5 `array` items;
  var average5 = function (array) {
    var sum = 0;
    for (var i = array.length - 1; i > array.length - 6; i--) {
      sum += array[i];
    }
    return sum / 5;
  };

  // Compass.js allow you to get compass heading in JavaScript.
  // We can get compass data by two proprietary APIs and one hack:
  // * PhoneGap have `navigator.compass` API.
  // * iOS Safari add `webkitCompassHeading` to `deviceorientation` event.
  // * We can enable GPS and ask user to go forward. GPS will send current heading,
  //   so we can calculate difference between real North and zero in
  //   `deviceorientation` event. Next we use this difference to get compass heading
  //   only by device orientation.
  //
  // Hide compass, when there isn’t any method:
  //
  //   Compass.noSupport(function () {
  //     $('.compass').hide();
  //   });
  //
  // Show instructions for GPS hack:
  //
  //   Compass.needGPS(function () {
  //     $('.go-outside-message').show();
  //   }).needMove(function () {
  //     $('.go-outside-message').hide()
  //     $('.move-and-hold-ahead-message').show();
  //   }).init(function () {
  //     $('.move-and-hold-ahead-message').hide();
  //   });
  var self = window.Compass = {

    // Name of method to get compass heading. It will have value only after
    // library initialization from `init` method. So better way to get
    // method name is to use `init`:
    //
    //   Compass.init(function (method) {
    //     console.log('Compass by ' + method);
    //   });
    //
    // Available methods:
    // * `phonegap` take from PhoneGap’s `navigator.compass`.
    // * `webkitOrientation` take from iPhone’s proprietary
    //   `webkitCompassHeading` proprerty in `DeviceOrientationEvent`.
    // * `orientationAndGPS` take from device orientation with GPS hack.
    //
    // If browser hasn’t access to compass, `method` will be `false`.
    method: undefined,

    // Watch for compass heading changes and execute `callback` with degrees
    // relative to magnetic north (from 0 to 360).
    //
    // Method return watcher ID to use it in `unwatch`.
    //
    //   var watchID = Compass.watch(function (heading) {
    //     $('.degrees').text(heading);
    //     // Don’t forget to change degree sign, when rotate compass.
    //     $('.compass').css({ transform: 'rotate(' + (-heading) + 'deg)' });
    //   });
    //
    //   someApp.close(function () {
    //     Compass.unwatch(watchID);
    //   });
    watch: function (callback) {
      var id = ++self._lastId;

      self.init(function (method) {

        if ( method == 'phonegap' ) {
          self._watchers[id] = self._nav.compass.watchHeading(callback);

        } else if ( method == 'webkitOrientation' ) {
          var watcher = function (e) {
            callback(e.webkitCompassHeading);
          };
          self._win.addEventListener('deviceorientation', watcher);
          self._watchers[id] = watcher;

        } else if ( method == 'orientationAndGPS' ) {
          var degrees;
          var watcher = function (e) {
            degrees = -e.alpha + self._gpsDiff;
            if ( degrees < 0 ) {
              degrees += 360;
            } else if ( degrees > 360 ) {
              degrees -= 360;
            }
            callback(degrees);
          };
          self._win.addEventListener('deviceorientation', watcher);
          self._watchers[id] = watcher;

        }
      });

      return id;
    },

    // Remove watcher by watcher ID from `watch`.
    //
    //   Compass.unwatch(watchID)
    unwatch: function (id) {
      self.init(function (m) {

        if ( m == 'phonegap' ) {
          self._nav.compass.clearWatch(self._watchers[id]);

        } else if ( m == 'webkitOrientation' || m == 'orientationAndGPS' ) {
          self._win.removeEventListener('deviceorientation', self._watchers[id]);

        }
        delete self._watchers[id];
      });
      return self;
    },

    // Execute `callback`, when GPS hack activated to detect difference between
    // device orientation and real North from GPS.
    //
    // You need to show to user some message, that he must go outside to be able
    // to receive GPS signal.
    //
    // Callback must be set before `init` or `watch` executing.
    //
    //   Compass.needGPS(function () {
    //     $('.go-outside-message').show();
    //   });
    //
    // Don’t forget to hide message by `needMove` callback in second step.
    needGPS: function (callback) {
      self._callbacks.needGPS.push(callback);
      return self;
    },

    // Execute `callback` on second GPS hack step, when library has GPS signal,
    // but user must move and hold the device straight ahead. Library will use
    // `heading` from GPS movement tracking to detect difference between
    // device orientation and real North.
    //
    // Callback must be set before `init` or `watch` executing.
    //
    //   Compass.needMove(function () {
    //     $('.go-outside-message').hide()
    //     $('.move-and-hold-ahead-message').show();
    //   });
    //
    // Don’t forget to hide message in `init` callback:
    //
    //   Compass.init(function () {
    //     $('.move-and-hold-ahead-message').hide();
    //   });
    needMove: function (callback) {
      self._callbacks.needMove.push(callback);
      return self;
    },

    // Execute `callback` if browser hasn’t any way to get compass heading.
    //
    //   Compass.noSupport(function () {
    //     $('.compass').hide();
    //   });
    //
    // On Firefox detecting can take about 0.5 second. So, it will be better
    // to show compass in `init`, than to hide it in `noSupport`.
    noSupport: function (callback) {
      if ( self.method === false ) {
        callback();
      } else if ( !defined(self.method) ) {
        self._callbacks.noSupport.push(callback);
      }
      return self;
    },

    // Detect compass method and execute `callback`, when library will be
    // initialized. Callback will get method name (or `false` if library can’t
    // detect compass) in first argument.
    //
    // It is best way to check `method` property.
    //
    //   Compass.init(function (method) {
    //     console.log('Compass by ' + method);
    //   });
    init: function (callback) {
      if ( defined(self.method) ) {
        callback(self.method);
        return;
      }
      self._callbacks.init.push(callback);

      if ( self._initing ) {
        return;
      }
      self._initing = true;

      if ( self._nav.compass ) {
        self._start('phonegap');

      } else if ( self._win.DeviceOrientationEvent ) {
        self._checking = 0;
        self._win.addEventListener('deviceorientation', self._checkEvent);
        setTimeout(function () {
          if ( self._checking !== false ) {
            self._start(false);
          }
        }, 500);

      } else {
        self._start(false);
      }
      return self;
    },

    // Last watch ID.
    _lastId: 0,

    // Hash of internal ID to watcher to use it in `unwatch`.
    _watchers: { },

    // Window object for testing.
    _win: window,

    // Navigator object for testing.
    _nav: navigator,

    // List of callbacks.
    _callbacks: {

      // Callbacks from `init` method.
      init: [],

      // Callbacks from `noSupport` method.
      noSupport: [],

      // Callbacks from `needGPS` method.
      needGPS: [],

      // Callbacks from `needMove` method.
      needMove: []

    },

    // Is library now try to detect compass method.
    _initing: false,

    // Difference between `alpha` orientation and real North from GPS.
    _gpsDiff: undefined,

    // Finish library initialization and use `method` to get compass heading.
    _start: function (method) {
      self.method   = method;
      self._initing = false;

      fire('init', [method]);
      self._callbacks.init = [];

      if ( method === false ) {
        fire('noSupport', []);
      }
      self._callbacks.noSupport = [];
    },

    // Tell, that we wait for `DeviceOrientationEvent`.
    _checking: false,

    // Check `DeviceOrientationEvent` to detect compass method.
    _checkEvent: function (e) {
      self._checking += 1;
      var wait = false;

      if ( defined(e.webkitCompassHeading) ) {
        self._start('webkitOrientation');

      } else if ( defined(e.alpha) && self._nav.geolocation ) {
        self._gpsHack();

      } else if ( self._checking > 1 ) {
        self._start(false);

      } else {
        wait = true;
      }

      if ( !wait ) {
        self._checking = false;
        self._win.removeEventListener('deviceorientation', self._checkEvent);
      }
    },

    // Use GPS to detect difference  between `alpha` orientation and real North.
    _gpsHack: function () {
      var first    = true;
      var alphas   = [];
      var headings = [];

      fire('needGPS');

      var saveAlpha = function (e) {
        alphas.push(e.alpha);
      }
      self._win.addEventListener('deviceorientation', saveAlpha);

      var success = function (position) {
        var coords = position.coords
        if ( !defined(coords.heading) ) {
          return; // Position not from GPS
        }

        if ( first ) {
          first = false;
          fire('needMove');
        }

        if ( coords.speed > 1 ) {
          headings.push(coords.heading);
          if ( headings.length >= 5 && alphas.length >= 5 ) {
            self._win.removeEventListener('deviceorientation', saveAlpha);
            self._nav.geolocation.clearWatch(watcher);

            self._gpsDiff = average5(headings) + average5(alphas);
            self._start('orientationAndGPS');
          }
        } else {
          headings = [];
        }
      };
      var error = function () {
        self._win.removeEventListener('deviceorientation', saveAlpha);
        self._start(false);
      };

      var watcher = self._nav.geolocation.
        watchPosition(success, error, { enableHighAccuracy: true });
    }

  };

})();
