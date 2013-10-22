(function() {
  var NotFoundError,
    __hasProp = {}.hasOwnProperty,
    __extends = function(child, parent) { for (var key in parent) { if (__hasProp.call(parent, key)) child[key] = parent[key]; } function ctor() { this.constructor = child; } ctor.prototype = parent.prototype; child.prototype = new ctor(); child.__super__ = parent.prototype; return child; };

  module.exports = NotFoundError = (function(_super) {
    __extends(NotFoundError, _super);

    function NotFoundError(message) {
      this.message = message;
    }

    return NotFoundError;

  })(Error);

}).call(this);
