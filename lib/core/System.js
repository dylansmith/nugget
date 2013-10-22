(function() {
  var System, utils,
    __bind = function(fn, me){ return function(){ return fn.apply(me, arguments); }; };

  utils = require('../utils');

  System = (function() {
    System.prototype.tickInterval = 1000;

    System.prototype.timer = null;

    /*
    @constructor
    */


    function System(name) {
      this.name = name;
      this.toString = __bind(this.toString, this);
      this.tick = __bind(this.tick, this);
      this.stop = __bind(this.stop, this);
      this.start = __bind(this.start, this);
      this.onRegister = __bind(this.onRegister, this);
      this.dispose = __bind(this.dispose, this);
    }

    /*
    @description Tears down the system
    */


    System.prototype.dispose = function() {};

    /*
    @description Registration hook
    */


    System.prototype.onRegister = function() {};

    /*
    @description Starts the system loop
    */


    System.prototype.start = function() {
      if (this.timer) {
        return utils.warn("" + this.name + " is already started");
      } else {
        utils.log("" + this.name + " has started");
        this.timer = setInterval(this.tick, this.tickInterval);
        return this.tick();
      }
    };

    /*
    @description Stops the system loop
    */


    System.prototype.stop = function() {
      if (!this.timer) {
        return utils.warn("" + this.name + " is already stopped");
      } else {
        clearInterval(this.timer);
        this.timer = null;
        return utils.log("" + this.name + " has stopped");
      }
    };

    /*
    @description The code which is run each iteration of the system loop
    */


    System.prototype.tick = function() {
      return utils.log("" + this.name + " tick!");
    };

    /*
    @description Returns a string representation of the system in the form System<name>
    @returns {string}
    */


    System.prototype.toString = function() {
      return "System<" + this.name + ">";
    };

    return System;

  })();

  module.exports = System;

}).call(this);
