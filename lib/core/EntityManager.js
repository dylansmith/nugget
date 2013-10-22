(function() {
  var Component, DuplicateComponentError, Entity, EntityManager, InvalidParamError, MissingParamError, NotFoundError, config, polyfills, utils,
    __bind = function(fn, me){ return function(){ return fn.apply(me, arguments); }; };

  config = require('../config');

  polyfills = require('../polyfills');

  utils = require('../utils');

  Entity = require('../core/Entity');

  Component = require('../core/Component');

  DuplicateComponentError = require('../exceptions/DuplicateComponentError');

  InvalidParamError = require('../exceptions/InvalidParamError');

  MissingParamError = require('../exceptions/MissingParamError');

  NotFoundError = require('../exceptions/NotFoundError');

  EntityManager = (function() {
    /*
    @constructor
    */

    function EntityManager() {
      this._requireComponentId = __bind(this._requireComponentId, this);
      this._requireComponent = __bind(this._requireComponent, this);
      this._requireEntity = __bind(this._requireEntity, this);
      this._generateId = __bind(this._generateId, this);
      this.toId = __bind(this.toId, this);
      this.removeAllEntities = __bind(this.removeAllEntities, this);
      this.removeEntity = __bind(this.removeEntity, this);
      this.removeComponent = __bind(this.removeComponent, this);
      this.registerEntity = __bind(this.registerEntity, this);
      this.hasEntity = __bind(this.hasEntity, this);
      this.hasAnyComponents = __bind(this.hasAnyComponents, this);
      this.hasAllComponents = __bind(this.hasAllComponents, this);
      this.hasComponent = __bind(this.hasComponent, this);
      this.getEntitiesByComponents = __bind(this.getEntitiesByComponents, this);
      this.getEntitiesByComponent = __bind(this.getEntitiesByComponent, this);
      this.getEntities = __bind(this.getEntities, this);
      this.getComponents = __bind(this.getComponents, this);
      this.getComponent = __bind(this.getComponent, this);
      this.createEntity = __bind(this.createEntity, this);
      this.createComponent = __bind(this.createComponent, this);
      this.addComponent = __bind(this.addComponent, this);
      this.componentMap = {};
      this.entityMap = {};
      this.entityKey = 0;
    }

    /*
    @description Adds a component instance to an entity instance
    @param {mixed} entityOrId An entity or entity id
    @param {object} componentInstance A Component instance
    */


    EntityManager.prototype.addComponent = function(entityOrId, component) {
      var entityId;
      this._requireEntity(entityOrId);
      this._requireComponent(component);
      entityId = this.toId(entityOrId);
      if (component.name in this.entityMap[entityId].components) {
        throw new DuplicateComponentError("Entity<" + entityId + "> already has Component<" + component.name + ">");
      } else {
        this.entityMap[entityId].components[component.name] = component;
        if (!(component.name in this.componentMap)) {
          this.componentMap[component.name] = {
            instances: [],
            by_entity: {}
          };
        }
        this.componentMap[component.name].instances.push(component);
        return this.componentMap[component.name].by_entity[entityId] = this.entityMap[entityId].components;
      }
    };

    /*
    @description Creates a new component instance
    @param {string} name The component name/id
    @param {mixed} [value] The base value
    @returns {nugget.core.Entity}
    */


    EntityManager.prototype.createComponent = function(name, val) {
      this._requireComponentId(name);
      return new Component(name, val);
    };

    /*
    @description Creates a new entity instance
    @param {string} [entityId] Optional entity ID
    @returns {nugget.core.Entity}
    */


    EntityManager.prototype.createEntity = function(entityId) {
      if (!entityId) {
        entityId = this._generateId();
      }
      if (config.debugging) {
        utils.log("Creating Entity<" + entityId + ">");
      }
      return new Entity(this, entityId);
    };

    /*
    @description Returns a component instance for an entity instance
    @param {mixed} entityOrId An entity or entity id
    @param {string} componentId The component id
    @returns {object} A component instance
    */


    EntityManager.prototype.getComponent = function(entityOrId, componentId) {
      var components, entityId;
      this._requireEntity(entityOrId);
      this._requireComponentId(componentId);
      entityId = this.toId(entityOrId);
      if (!this.hasComponent(entityId, componentId)) {
        throw new NotFoundError("Component<" + componentId + "> not found for Entity<" + entityId + ">");
      }
      components = this.getComponents(entityId);
      return components[componentId];
    };

    /*
    @description Returns a hash of the component instances keyed by their component class name
    @param {mixed} entityOrId An entity or entity id
    @returns {object} A hash of all component instances, keyed by component name
    */


    EntityManager.prototype.getComponents = function(entityOrId) {
      var entityId;
      this._requireEntity(entityOrId);
      entityId = this.toId(entityOrId);
      if (!(entityId in this.entityMap)) {
        throw new NotFoundError("Entity<" + entityId + "> not found");
      }
      return this.entityMap[entityId].components;
    };

    EntityManager.prototype.getEntities = function(componentSelector) {
      var c, comps, excl, incl, out, _i, _len,
        _this = this;
      comps = componentSelector.toString().split(',');
      incl = [];
      excl = [];
      out = {};
      for (_i = 0, _len = comps.length; _i < _len; _i++) {
        c = comps[_i];
        c = c.trim();
        if (c[0] !== '-') {
          incl.push(c);
        } else {
          excl.push(c.strip('-'));
        }
      }
      return utils.filter(this.getEntitiesByComponents(incl), function(k, v) {
        return _this.hasAnyComponents(v, excl) === false;
      });
    };

    /*
    @description Returns a hash with entity IDs as the keys and a hash of their
        component instances keyed by their component name
    @param {string} componentId The component id
    @returns {object}
    */


    EntityManager.prototype.getEntitiesByComponent = function(componentId) {
      var entities, entitiesByComponent, k, v;
      this._requireComponentId(componentId);
      entities = {};
      if (!(componentId in this.componentMap)) {
        return entities;
      }
      entitiesByComponent = this.componentMap[componentId].by_entity;
      for (k in entitiesByComponent) {
        v = entitiesByComponent[k];
        entities[k] = this.entityMap[k].instance;
      }
      return entities;
    };

    /*
    @description Returns a hash with entity IDs as the keys and a hash of their
        component instances keyed by their component class name
    @param {string} componentIds An array of component ids
    @returns {object}
    */


    EntityManager.prototype.getEntitiesByComponents = function(componentIds) {
      var entities, id, _i, _len;
      if (!componentIds) {
        throw new MissingParamError('Expects an array of component names');
      }
      entities = {};
      for (_i = 0, _len = componentIds.length; _i < _len; _i++) {
        id = componentIds[_i];
        utils.extend(entities, this.getEntitiesByComponent(id));
      }
      return entities;
    };

    /*
    @description Determines whether an entity instance has a specified component instance
    @param {mixed} entityOrId An entity or entity id
    @param {string} componentId The component id
    */


    EntityManager.prototype.hasComponent = function(entityOrId, componentId) {
      var components;
      this._requireEntity(entityOrId);
      this._requireComponentId(componentId);
      components = this.getComponents(this.toId(entityOrId));
      return componentId in components;
    };

    /*
    @description Determines whether an entity instance has all specified components
    @param {mixed} entityOrId An entity or entity id
    @param {object} componentIds An array of component ids
    */


    EntityManager.prototype.hasAllComponents = function(entityOrId, componentIds) {
      var components, name, _i, _len;
      this._requireEntity(entityOrId);
      if (utils.type(componentIds) !== 'array') {
        throw new InvalidParamError('Expects an array of component names');
      }
      components = this.getComponents(this.toId(entityOrId));
      for (_i = 0, _len = componentIds.length; _i < _len; _i++) {
        name = componentIds[_i];
        if (!(name in components)) {
          return false;
        }
      }
      return true;
    };

    /*
    @description Determines whether an entity instance has any of the specified components
    @param {mixed} entityOrId An entity or entity id
    @param {object} componentIds An array of component ids
    */


    EntityManager.prototype.hasAnyComponents = function(entityOrId, componentIds) {
      var components, name, _i, _len;
      this._requireEntity(entityOrId);
      if (utils.type(componentIds) !== 'array') {
        throw new InvalidParamError('Expects an array of component names');
      }
      components = this.getComponents(this.toId(entityOrId));
      for (_i = 0, _len = componentIds.length; _i < _len; _i++) {
        name = componentIds[_i];
        if (name in components) {
          return true;
        }
      }
      return false;
    };

    /*
    @description Determines whether an entity instance exists
    @param {mixed} entityOrId An entity or entity id
    @returns {boolean}
    */


    EntityManager.prototype.hasEntity = function(entityOrId) {
      var entityId;
      this._requireEntity(entityOrId, false);
      entityId = this.toId(entityOrId);
      return entityId in this.entityMap;
    };

    /*
    @description Registers an existing entity with the manager
    @param {object} entityInstance The entity instance
    */


    EntityManager.prototype.registerEntity = function(entityInstance) {
      if (!(entityInstance && entityInstance.constructor === Entity)) {
        throw new InvalidParamError('Expects an entity instance');
      }
      if (entityInstance.id in this.entityMap) {
        throw new InvalidParamError("Entity<" + entityInstance.id + "> is already registered with this EntityManager");
      }
      if (!entityInstance.id) {
        entityInstance.id = this._generateId();
      }
      return this.entityMap[entityInstance.id] = {
        instance: entityInstance,
        components: {}
      };
    };

    /*
    @description Remove a component instance from an entity instance
    @param {mixed} entityOrId An entity or entity id
    @param {string} componentId The component id
    */


    EntityManager.prototype.removeComponent = function(entityOrId, componentId) {
      var cmap, component, components, entityId, i;
      this._requireEntity(entityOrId);
      this._requireComponentId(componentId);
      entityId = this.toId(entityOrId);
      components = this.getComponents(entityId);
      if (!(componentId in components)) {
        throw new NotFoundError("Component<" + componentId + "> not found for Entity<" + entityId + ">");
      } else {
        cmap = this.componentMap[componentId];
        component = this.entityMap[entityId].components[componentId];
        i = cmap.instances.indexOf(component);
        cmap.instances.splice(i, 1);
        cmap.by_entity[entityId] = null;
        delete cmap.by_entity[entityId];
        this.entityMap[entityId].components[componentId] = null;
        delete this.entityMap[entityId].components[componentId];
        return component;
      }
    };

    /*
    @description Removes an entity instance
    @param {mixed} entityOrId An entity or entity id
    */


    EntityManager.prototype.removeEntity = function(entityOrId) {
      var components, entityId, k;
      this._requireEntity(entityOrId);
      entityId = this.toId(entityOrId);
      if (!this.hasEntity(entityId)) {
        throw new NotFoundError("Entity<" + entityId + "> not found");
      }
      components = this.getComponents(entityId);
      for (k in components) {
        this.removeComponent(entityId, k);
      }
      this.entityMap[entityId] = null;
      return delete this.entityMap[entityId];
    };

    /*
    @description Removes all entity instances
    */


    EntityManager.prototype.removeAllEntities = function() {
      var id;
      for (id in this.entityMap) {
        this.removeEntity(id);
      }
      return this.entityKey = 0;
    };

    /*
    @description Resolves an object or id into an id
    @param {mixed} objOrId
    */


    EntityManager.prototype.toId = function(objOrId) {
      if (objOrId && utils.type(objOrId) === 'object' && objOrId.id) {
        return objOrId.id;
      } else {
        return objOrId;
      }
    };

    /*
    @description Generates the next entity id
    @returns {string}
    */


    EntityManager.prototype._generateId = function() {
      return "entity_" + (++this.entityKey);
    };

    /*
    @description Helper to prevent duplication of function argument validation
    @param {mixed} entityOrId An entity or entity id
    @param {boolean} [checkExists] additionally check whether the entity is registered (true)
    @returns {string}
    */


    EntityManager.prototype._requireEntity = function(entityOrId, checkExists) {
      var entityId;
      if (checkExists == null) {
        checkExists = true;
      }
      if (!entityOrId) {
        throw new MissingParamError('Expects an entity instance or id');
      }
      entityId = this.toId(entityOrId);
      if (checkExists && !(entityId in this.entityMap)) {
        throw new NotFoundError("Entity<" + entityId + "> not found");
      }
      return entityId;
    };

    /*
    @description Helper to prevent duplication of function argument validation
    @param {string} componen A component instance
    */


    EntityManager.prototype._requireComponent = function(component) {
      if (!component) {
        throw new MissingParamError('Expects a component instance');
      }
      if (component.constructor !== Component) {
        throw new InvalidParamError('Not a valid component instance');
      }
    };

    /*
    @description Helper to prevent duplication of function argument validation
    @param {string} componentId A component id/name
    */


    EntityManager.prototype._requireComponentId = function(componentId) {
      if (!componentId) {
        throw new MissingParamError('Expects a component name');
      }
      if (componentId.constructor === Component) {
        throw new InvalidParamError('Expects a component name, not a Component instance');
      }
    };

    return EntityManager;

  })();

  module.exports = EntityManager;

}).call(this);
