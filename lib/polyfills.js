(function() {
  var polyfills;

  polyfills = function() {
    String.prototype.trim = function() {
      return this.replace(/^\s+|\s+$/g, '');
    };
    String.prototype.ltrim = function() {
      return this.replace(/^\s+/g, '');
    };
    String.prototype.rtrim = function() {
      return this.replace(/\s+$/g, '');
    };
    String.prototype.strip = function(char) {
      if (char == null) {
        return this.trim;
      }
      return this.replace(new RegExp("^" + char + "+|" + char + "+$", 'g'), '');
    };
    if (!Array.prototype.filter) {
      return Array.prototype.filter = function(callback) {
        var element, _i, _len, _results;
        _results = [];
        for (_i = 0, _len = this.length; _i < _len; _i++) {
          element = this[_i];
          if (callback(element)) {
            _results.push(element);
          }
        }
        return _results;
      };
    }
  };

  polyfills();

  module.exports = polyfills;

}).call(this);
