InvalidParamError = require('../exceptions/InvalidParamError')
MissingParamError = require('../exceptions/MissingParamError')

class Entity

    ###
    @constructor
    @param {object} manager An entity manager instance
    @param {string} [id] An optional id to use for the entity
    ###
    constructor: (@manager, @id) ->
        unless @manager
            throw new MissingParamError('Expects an EntityManager instance')

        unless @manager.constructor.name is 'EntityManager'
            throw new InvalidParamError('Not a valid EntityManager instance')

        @manager.registerEntity(this, @id)

    ###
    @description Adds a component instance to the entity instance
    @param {object} componentInstance
    ###
    add: (componentId, val) =>
        unless componentId
            throw new MissingParamError('Expects a component name')

        component = @manager.createComponent(componentId, val)
        @manager.addComponent(@id, component)
        return component

    ###
    @description Destroy the entity
    ###
    dispose: =>
        @manager.removeEntity(this)
        delete this

    ###
    @description Retrieves a component instance from the entity
    @param {string} componentId The component name
    @returns {object} The component instance
    ###
    get: (componentId) =>
        @manager.getComponent(@id, componentId)

    ###
    @description Gets all components registered to this Entity instance
    @returns {object} A hash of all component instances, keyed by component name
    ###
    getAll: =>
        @manager.getComponents(@id)

    ###
    @description Determines whether the entity has a specified component
    @param {string} componentId The component name
    @returns {boolean}
    ###
    has: (componentId) =>
        @manager.hasComponent(@id, componentId)

    ###
    @description Determines whether the entity has a specified component
    @param {array} componentIds An array of component ids
    @returns {boolean}
    ###
    hasAll: (componentIds) =>
        @manager.hasAllComponents(@id, componentIds)

    ###
    @description Removes a component from the entity instance
    @param {string} componentId The component name
    @returns {object} The removed component instance
    ###
    remove: (componentId) =>
        @manager.removeComponent(@id, componentId)

    ###
    @description Returns a string representation of the entity in the form Entity<id>
    @returns {string}
    ###
    toString: =>
        return "Entity<#{@id}>"

module.exports = Entity
