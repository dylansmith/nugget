/*! nugget - v0.1.0 - 2013-10-22
* https://github.com/dylansmith/nugget-commonjs
* Copyright (c) 2013 Dylan Smith; Licensed MIT */
(function() {
  var nugget;

  require('../src/polyfills');

  nugget = {
    Component: require('./core/Component'),
    System: require('./core/System'),
    Entity: require('./core/Entity'),
    EntityManager: require('./core/EntityManager'),
    SystemManager: require('./core/SystemManager'),
    World: require('./core/World'),
    config: require('./config'),
    utils: require('./utils')
  };

  module.exports = nugget;

}).call(this);
