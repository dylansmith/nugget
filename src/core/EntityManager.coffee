config = require('../config')
polyfills = require('../polyfills')
utils = require('../utils')
Entity = require('../core/Entity')
Component = require('../core/Component')
DuplicateComponentError = require('../exceptions/DuplicateComponentError')
InvalidParamError = require('../exceptions/InvalidParamError')
MissingParamError = require('../exceptions/MissingParamError')
NotFoundError = require('../exceptions/NotFoundError')

class EntityManager

    ###
    @constructor
    ###
    constructor: ->
        @componentMap = {}
        @entityMap = {}
        @entityKey = 0

    ###
    @description Adds a component instance to an entity instance
    @param {mixed} entityOrId An entity or entity id
    @param {object} componentInstance A Component instance
    ###
    addComponent: (entityOrId, component) =>
        @_requireEntity(entityOrId)
        @_requireComponent(component)

        entityId = @toId(entityOrId)
        if component.name of @entityMap[entityId].components
            throw new DuplicateComponentError("Entity<#{entityId}> already has Component<#{ component.name }>")
        else
            @entityMap[entityId].components[component.name] = component
            if component.name not of @componentMap
                @componentMap[component.name] = {
                    instances: []
                    by_entity: {}
                }

            @componentMap[component.name].instances.push(component)
            @componentMap[component.name].by_entity[entityId] = @entityMap[entityId].components

    ###
    @description Creates a new component instance
    @param {string} name The component name/id
    @param {mixed} [value] The base value
    @returns {nugget.core.Entity}
    ###
    createComponent: (name, val) =>
        @_requireComponentId(name)
        return new Component(name, val)
        # class name extends Component
        # name[k] = v for k,v of members
        # return name
        # return new Component(name, value)

    ###
    @description Creates a new entity instance
    @param {string} [entityId] Optional entity ID
    @returns {nugget.core.Entity}
    ###
    createEntity: (entityId) =>
        entityId = @_generateId() unless entityId
        if config.debugging
            utils.log "Creating Entity<#{entityId}>"
        return new Entity(this, entityId)

    ###
    @description Returns a component instance for an entity instance
    @param {mixed} entityOrId An entity or entity id
    @param {string} componentId The component id
    @returns {object} A component instance
    ###
    getComponent: (entityOrId, componentId) =>
        @_requireEntity(entityOrId)
        @_requireComponentId(componentId)

        entityId = @toId(entityOrId)
        unless @hasComponent(entityId, componentId)
            throw new NotFoundError("Component<#{componentId}> not found for Entity<#{entityId}>")

        components = @getComponents(entityId)
        return components[componentId]

    ###
    @description Returns a hash of the component instances keyed by their component class name
    @param {mixed} entityOrId An entity or entity id
    @returns {object} A hash of all component instances, keyed by component name
    ###
    getComponents: (entityOrId) =>
        @_requireEntity(entityOrId)
        entityId = @toId(entityOrId)
        unless entityId of @entityMap
            throw new NotFoundError("Entity<#{entityId}> not found")

        return @entityMap[entityId].components

    getEntities: (componentSelector) =>
        comps = componentSelector.toString().split(',')
        incl = []
        excl = []
        out = {}
        for c in comps
            c = c.trim()
            unless c[0] is '-' then incl.push(c) else excl.push(c.strip('-'))

        return utils.filter(@getEntitiesByComponents(incl), (k, v) => @hasAnyComponents(v, excl) is false)

    ###
    @description Returns a hash with entity IDs as the keys and a hash of their
        component instances keyed by their component name
    @param {string} componentId The component id
    @returns {object}
    ###
    getEntitiesByComponent: (componentId) =>
        @_requireComponentId(componentId)

        entities = {}
        return entities if componentId not of @componentMap
        entitiesByComponent = @componentMap[componentId].by_entity
        for k,v of entitiesByComponent
            entities[k] = @entityMap[k].instance
        return entities

    ###
    @description Returns a hash with entity IDs as the keys and a hash of their
        component instances keyed by their component class name
    @param {string} componentIds An array of component ids
    @returns {object}
    ###
    getEntitiesByComponents: (componentIds) =>
        unless componentIds
            throw new MissingParamError('Expects an array of component names')

        entities = {}
        for id in componentIds
            utils.extend(entities, @getEntitiesByComponent(id))
        return entities

    ###
    @description Determines whether an entity instance has a specified component instance
    @param {mixed} entityOrId An entity or entity id
    @param {string} componentId The component id
    ###
    hasComponent: (entityOrId, componentId) =>
        @_requireEntity(entityOrId)
        @_requireComponentId(componentId)
        components = @getComponents(@toId(entityOrId))
        return componentId of components

    ###
    @description Determines whether an entity instance has all specified components
    @param {mixed} entityOrId An entity or entity id
    @param {object} componentIds An array of component ids
    ###
    hasAllComponents: (entityOrId, componentIds) =>
        @_requireEntity(entityOrId)

        unless utils.type(componentIds) is 'array'
            throw new InvalidParamError('Expects an array of component names')

        components = @getComponents(@toId(entityOrId))
        for name in componentIds
            if name not of components
                return false

        return true

    ###
    @description Determines whether an entity instance has any of the specified components
    @param {mixed} entityOrId An entity or entity id
    @param {object} componentIds An array of component ids
    ###
    hasAnyComponents: (entityOrId, componentIds) =>
        @_requireEntity(entityOrId)

        unless utils.type(componentIds) is 'array'
            throw new InvalidParamError('Expects an array of component names')

        components = @getComponents(@toId(entityOrId))
        for name in componentIds
            return true if name of components

        return false

    ###
    @description Determines whether an entity instance exists
    @param {mixed} entityOrId An entity or entity id
    @returns {boolean}
    ###
    hasEntity: (entityOrId) =>
        @_requireEntity(entityOrId, false)
        entityId = @toId(entityOrId)
        return entityId of @entityMap

    ###
    @description Registers an existing entity with the manager
    @param {object} entityInstance The entity instance
    ###
    registerEntity: (entityInstance) =>
        unless entityInstance and entityInstance.constructor is Entity
            throw new InvalidParamError('Expects an entity instance')

        if entityInstance.id of @entityMap
            throw new InvalidParamError("Entity<#{entityInstance.id}> is already registered with this EntityManager")

        unless entityInstance.id
            entityInstance.id = @_generateId()

        @entityMap[entityInstance.id] =
            instance: entityInstance
            components: {}

    ###
    @description Remove a component instance from an entity instance
    @param {mixed} entityOrId An entity or entity id
    @param {string} componentId The component id
     ###
    removeComponent: (entityOrId, componentId) =>
        @_requireEntity(entityOrId)
        @_requireComponentId(componentId)

        entityId = @toId(entityOrId)
        components = @getComponents(entityId)
        unless componentId of components
            throw new NotFoundError("Component<#{componentId}> not found for Entity<#{entityId}>")
        else
            cmap = @componentMap[componentId]
            component = @entityMap[entityId].components[componentId]

            # remove the component instance from the component map
            i = cmap.instances.indexOf(component)
            cmap.instances.splice(i, 1)

            # remove the entity from the component map
            cmap.by_entity[entityId] = null
            delete cmap.by_entity[entityId]

            # destroy the entity map entry
            @entityMap[entityId].components[componentId] = null
            delete @entityMap[entityId].components[componentId]

            return component

    ###
    @description Removes an entity instance
    @param {mixed} entityOrId An entity or entity id
    ###
    removeEntity: (entityOrId) =>
        @_requireEntity(entityOrId)

        entityId = @toId(entityOrId)
        unless @hasEntity(entityId)
            throw new NotFoundError("Entity<#{entityId}> not found")

        # remove the componentMap entries
        components = @getComponents(entityId)
        @removeComponent(entityId, k) for k of components

        # remove the entityMap entry
        @entityMap[entityId] = null
        delete @entityMap[entityId]

    ###
    @description Removes all entity instances
    ###
    removeAllEntities: =>
        @removeEntity(id) for id of @entityMap
        @entityKey = 0

    ###
    @description Resolves an object or id into an id
    @param {mixed} objOrId
    ###
    toId: (objOrId) =>
        if objOrId and utils.type(objOrId) is 'object' and objOrId.id
            return objOrId.id
        else
            return objOrId

    ###
    @description Generates the next entity id
    @returns {string}
    ###
    _generateId: =>
        return "entity_#{++@entityKey}"

    ###
    @description Helper to prevent duplication of function argument validation
    @param {mixed} entityOrId An entity or entity id
    @param {boolean} [checkExists] additionally check whether the entity is registered (true)
    @returns {string}
    ###
    _requireEntity: (entityOrId, checkExists = true) =>
        unless entityOrId
            throw new MissingParamError('Expects an entity instance or id')

        entityId = @toId(entityOrId)
        if checkExists and entityId not of @entityMap
            throw new NotFoundError("Entity<#{entityId}> not found")

        return entityId

    ###
    @description Helper to prevent duplication of function argument validation
    @param {string} componen A component instance
    ###
    _requireComponent: (component) =>
        unless component
            throw new MissingParamError('Expects a component instance')
        unless component.constructor is Component
            throw new InvalidParamError('Not a valid component instance')

    ###
    @description Helper to prevent duplication of function argument validation
    @param {string} componentId A component id/name
    ###
    _requireComponentId: (componentId) =>
        unless componentId
            throw new MissingParamError('Expects a component name')
        if componentId.constructor is Component
            throw new InvalidParamError('Expects a component name, not a Component instance')

module.exports = EntityManager
