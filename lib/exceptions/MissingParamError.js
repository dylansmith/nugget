(function() {
  var MissingParamError,
    __hasProp = {}.hasOwnProperty,
    __extends = function(child, parent) { for (var key in parent) { if (__hasProp.call(parent, key)) child[key] = parent[key]; } function ctor() { this.constructor = child; } ctor.prototype = parent.prototype; child.prototype = new ctor(); child.__super__ = parent.prototype; return child; };

  module.exports = MissingParamError = (function(_super) {
    __extends(MissingParamError, _super);

    function MissingParamError(message) {
      this.message = message;
    }

    return MissingParamError;

  })(Error);

}).call(this);
