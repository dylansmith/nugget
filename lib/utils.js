(function() {
  var utils;

  utils = (function() {
    function utils() {}

    utils.ansi = {
      reset: '\u001b[0m',
      end: '\u001b[0m',
      bold: '\u001b[1m',
      italic: '\u001b[3m',
      underline: '\u001b[4m',
      blink: '\u001b[5m',
      black: '\u001b[30m',
      red: '\u001b[31m',
      green: '\u001b[32m',
      yellow: '\u001b[33m',
      blue: '\u001b[34m',
      magenta: '\u001b[35m',
      cyan: '\u001b[36m',
      white: '\u001b[37m'
    };

    utils.log = function() {
      var args, i, _i, _len;
      args = ['[LOG] '];
      for (_i = 0, _len = arguments.length; _i < _len; _i++) {
        i = arguments[_i];
        args.push(i);
      }
      return console.log.apply(utils, args);
    };

    utils.warn = function() {
      var args, i, _i, _len;
      args = ['[WARN] '];
      for (_i = 0, _len = arguments.length; _i < _len; _i++) {
        i = arguments[_i];
        args.push(i);
      }
      return console.warn.apply(utils, args);
    };

    utils.error = function() {
      var args, i, _i, _len;
      args = ['[ERROR] '];
      for (_i = 0, _len = arguments.length; _i < _len; _i++) {
        i = arguments[_i];
        args.push(i);
      }
      return console.error.apply(utils, args);
    };

    utils.colorize = function(str, name) {
      if (str.toString != null) {
        str = str.toString();
      }
      if (utils.ansi[name] != null) {
        return utils.ansi[name] + str + utils.ansi.end;
      } else {
        return str;
      }
    };

    utils.extend = function(object, properties) {
      var key, val;
      for (key in properties) {
        val = properties[key];
        object[key] = val;
      }
      return object;
    };

    utils.filter = function(object, callback) {
      var i, k, result, type, v;
      type = utils.type(object);
      if (type === 'object') {
        result = {};
        for (k in object) {
          v = object[k];
          if (callback(k, v) === true) {
            result[k] = v;
          }
        }
        return result;
      } else if (type === 'array') {
        return (function() {
          var _i, _len, _results;
          _results = [];
          for (i = _i = 0, _len = object.length; _i < _len; i = ++_i) {
            v = object[i];
            if (callback(v) === true) {
              _results.push(v);
            }
          }
          return _results;
        })();
      }
    };

    utils.first = function(object) {
      var k, v;
      if (object.length != null) {
        return object[0];
      }
      if (utils.type(object) === 'object') {
        for (k in object) {
          v = object[k];
          return v;
        }
      } else {
        return object;
      }
    };

    utils.keys = function(object) {
      var k;
      if (utils.type(object) === 'object') {
        return (function() {
          var _results;
          _results = [];
          for (k in object) {
            _results.push(k);
          }
          return _results;
        })();
      }
      return null;
    };

    utils.microtime = function() {
      return new Date().getTime();
    };

    utils.len = function(object) {
      if (object.length != null) {
        return object.length;
      }
      if (utils.type(object) === 'object') {
        return utils.keys(object).length;
      } else {
        return null;
      }
    };

    utils.rand = function(min, max) {
      return Math.floor(Math.random() * (max - min + 1)) + min;
    };

    utils.type = function(obj) {
      var classToType, myClass, name, _i, _len, _ref;
      if (obj === void 0 || obj === null) {
        return String(obj);
      }
      classToType = new Object;
      _ref = "Boolean Number String Function Array Date RegExp".split(" ");
      for (_i = 0, _len = _ref.length; _i < _len; _i++) {
        name = _ref[_i];
        classToType["[object " + name + "]"] = name.toLowerCase();
      }
      myClass = Object.prototype.toString.call(obj);
      if (myClass in classToType) {
        return classToType[myClass];
      }
      return "object";
    };

    return utils;

  }).call(this);

  module.exports = utils;

}).call(this);
