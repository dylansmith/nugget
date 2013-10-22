(function() {
  var Entity, InvalidParamError, MissingParamError,
    __bind = function(fn, me){ return function(){ return fn.apply(me, arguments); }; };

  InvalidParamError = require('../exceptions/InvalidParamError');

  MissingParamError = require('../exceptions/MissingParamError');

  Entity = (function() {
    /*
    @constructor
    @param {object} manager An entity manager instance
    @param {string} [id] An optional id to use for the entity
    */

    function Entity(manager, id) {
      this.manager = manager;
      this.id = id;
      this.toString = __bind(this.toString, this);
      this.remove = __bind(this.remove, this);
      this.hasAll = __bind(this.hasAll, this);
      this.has = __bind(this.has, this);
      this.getAll = __bind(this.getAll, this);
      this.get = __bind(this.get, this);
      this.dispose = __bind(this.dispose, this);
      this.add = __bind(this.add, this);
      if (!this.manager) {
        throw new MissingParamError('Expects an EntityManager instance');
      }
      if (this.manager.constructor.name !== 'EntityManager') {
        throw new InvalidParamError('Not a valid EntityManager instance');
      }
      this.manager.registerEntity(this, this.id);
    }

    /*
    @description Adds a component instance to the entity instance
    @param {object} componentInstance
    */


    Entity.prototype.add = function(componentId, val) {
      var component;
      if (!componentId) {
        throw new MissingParamError('Expects a component name');
      }
      component = this.manager.createComponent(componentId, val);
      this.manager.addComponent(this.id, component);
      return component;
    };

    /*
    @description Destroy the entity
    */


    Entity.prototype.dispose = function() {
      this.manager.removeEntity(this);
      return delete this;
    };

    /*
    @description Retrieves a component instance from the entity
    @param {string} componentId The component name
    @returns {object} The component instance
    */


    Entity.prototype.get = function(componentId) {
      return this.manager.getComponent(this.id, componentId);
    };

    /*
    @description Gets all components registered to this Entity instance
    @returns {object} A hash of all component instances, keyed by component name
    */


    Entity.prototype.getAll = function() {
      return this.manager.getComponents(this.id);
    };

    /*
    @description Determines whether the entity has a specified component
    @param {string} componentId The component name
    @returns {boolean}
    */


    Entity.prototype.has = function(componentId) {
      return this.manager.hasComponent(this.id, componentId);
    };

    /*
    @description Determines whether the entity has a specified component
    @param {array} componentIds An array of component ids
    @returns {boolean}
    */


    Entity.prototype.hasAll = function(componentIds) {
      return this.manager.hasAllComponents(this.id, componentIds);
    };

    /*
    @description Removes a component from the entity instance
    @param {string} componentId The component name
    @returns {object} The removed component instance
    */


    Entity.prototype.remove = function(componentId) {
      return this.manager.removeComponent(this.id, componentId);
    };

    /*
    @description Returns a string representation of the entity in the form Entity<id>
    @returns {string}
    */


    Entity.prototype.toString = function() {
      return "Entity<" + this.id + ">";
    };

    return Entity;

  })();

  module.exports = Entity;

}).call(this);
