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
  window.Compass = {

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

    // Execute `callback` if browser hasn’t any way to get compass heading.
    //
    //   Compass.noSupport(function () {
    //     $('.compass').hide();
    //   });
    noSupport: function (callback) {
      if ( this.method === false ) {
        callback();
      } else if ( !defined(this.method) ) {
        this._callbacks.noSupport.push(callback);
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
      if ( defined(this.method) ) {
        callback(this.method);
        return;
      }
      this._callbacks.init.push(callback);

      if ( this._initing ) {
        return;
      }
      this._initing = true;

      if ( this._nav.compass ) {
        this._start('phonegap');

      } else if ( this._win.DeviceOrientationEvent ) {
        this._win.addEventListener('deviceorientation', this._checkEvent);

      } else {
        this._start(false);
      }
    },

    // Window object for testing.s
    _win: window,

    // Navigator object for testing.s
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
        Compass._start('webkitOrientation');

      } else {
        Compass._start(false);
      }

      this._win.removeEventListener('deviceorientation', Compass._checkEvent);
    },

    // Finish library initialization and use `method` to get compass heading.
    _start: function (method) {
      this.method   = method;
      this._initing = false;

      for ( var i = 0; i < this._callbacks.init.length; i++ ) {
        this._callbacks.init[i](method);
      }
      this._callbacks.init = [];

      if ( method === false ) {
        for ( var i = 0; i < this._callbacks.noSupport.length; i++ ) {
          this._callbacks.noSupport[i]();
        }
      }
      this._callbacks.noSupport = [];
    }

  };

}).call(this);
