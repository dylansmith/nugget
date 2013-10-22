(function() {
  var Component,
    __bind = function(fn, me){ return function(){ return fn.apply(me, arguments); }; };

  Component = (function() {
    /*
    Contains custom properties for the component
    @type {object}
    */

    Component.prototype.props = {};

    /*
    A default value for the component
    @type {mixed}
    */


    Component.prototype.value = null;

    /*
    @constructor
    */


    function Component(name, value) {
      this.name = name;
      this.value = value;
      this.val = __bind(this.val, this);
      this.toString = __bind(this.toString, this);
      this.set = __bind(this.set, this);
      this.get = __bind(this.get, this);
      if (!this.name) {
        throw 'Component requires a name parameter';
      }
    }

    /*
    @description Gets a custom property
    @param {string} key The property key
    @returns {mixed} The value
    */


    Component.prototype.get = function(key) {
      if (this.props[key] != null) {
        return this.props[key];
      } else {
        return null;
      }
    };

    /*
    @description Sets a custom property
    @param {string} key The property key
    @param {mixed} val The property value
    @returns {object} the component instance
    */


    Component.prototype.set = function(key, val) {
      this.props[key] = val;
      return this;
    };

    /*
    @description Returns a string representation of the component in the form Component<name>
    @returns {string}
    */


    Component.prototype.toString = function() {
      return "Component<" + this.name + ">";
    };

    /*
    @description Gets a custom property
    @param {string} key The property key
    @returns {mixed} The value
    */


    Component.prototype.val = function(v) {
      if (v != null) {
        this.value = v;
      }
      return this.value;
    };

    return Component;

  })();

  module.exports = Component;

}).call(this);
