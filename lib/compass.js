/*
 * Copyright 2012 Andrey “A.I.” Sitnik <andrey@sitnik.ru>.
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

;(function($) {
  "use strict";

  var defined = function (variable) {
      return (typeof(variable) != 'undefined');
  };

  //
  var self = window.Compass = {

    // Name of method to get compass heading. It will have value only after
    // library initialization from `init` method. So better way to get
    // method name is:
    //
    //   Compass.init(function (method) {
    //     console.log('Compass by ' + method);
    //   });
    //
    // Available methods:
    // * `phonegap` take from PhoneGap’s `navigator.compass`.
    // * `webkitOrientation` take from iPhone’s proprietary
    //   `webkitCompassHeading` proprerty in `DeviceOrientationEvent`.
    //
    // If browser hasn’t access to compass, `method` will be `false`.
    method: undefined,

    // Watch for compass heading changes and execute `callback` with degrees
    // relative to magnetic north.
    //
    // Method return watcher ID to use it in `unwatch`.
    //
    //   var watchID = Compass.watch(function (heading) {
    //     $('.compass').css({ transform: 'rotate(' + heading + 'deg)' });
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

        }
      });

      return id;
    },

    // Remove watcher by watcher ID from `watch`.
    //
    //   Compass.unwatch(watchID)
    unwatch: function (id) {
      self.init(function (method) {

        if ( method == 'phonegap' ) {
          self._nav.compass.clearWatch(self._watchers[id]);

        } else if ( method == 'webkitOrientation' ) {
          self._win.removeEventListener('deviceorientation', self._watchers[id]);

        }
        delete self._watchers[id];
      });
    },

    // Execute `callback` if browser hasn’t any way to get compass heading.
    //
    //   Compass.noSupport(function () {
    //     $('.compass').hide();
    //   });
    noSupport: function (callback) {
      if ( self.method === false ) {
        callback();
      } else if ( !defined(self.method) ) {
        self._callbacks.noSupport.push(callback);
      }
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
        self._win.addEventListener('deviceorientation', self._checkEvent);

      } else {
        self._start(false);
      }
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

      // Callbacks for `init` method.
      init: [],

      // Callbacks for `noSupport` method.
      noSupport: []

    },

    // Is library now try to detect compass method.
    _initing: false,

    // Check `DeviceOrientationEvent` to detect compass method.
    _checkEvent: function (e) {
      if ( defined(e.webkitCompassHeading) ) {
        self._start('webkitOrientation');

      } else {
        self._start(false);
      }

      self._win.removeEventListener('deviceorientation', self._checkEvent);
    },

    // Finish library initialization and use `method` to get compass heading.
    _start: function (method) {
      self.method   = method;
      self._initing = false;

      for ( var i = 0; i < self._callbacks.init.length; i++ ) {
        self._callbacks.init[i](method);
      }
      self._callbacks.init = [];

      if ( method === false ) {
        for ( var i = 0; i < self._callbacks.noSupport.length; i++ ) {
          self._callbacks.noSupport[i]();
        }
      }
      self._callbacks.noSupport = [];
    }

  };

})();
