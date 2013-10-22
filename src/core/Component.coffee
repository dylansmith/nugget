class Component

    ###
    Contains custom properties for the component
    @type {object}
    ###
    props: {}

    ###
    A default value for the component
    @type {mixed}
    ###
    value: null

    ###
    @constructor
    ###
    constructor: (@name, @value) ->
        if not @name
            throw 'Component requires a name parameter'

    ###
    @description Gets a custom property
    @param {string} key The property key
    @returns {mixed} The value
    ###
    get: (key) =>
        if @props[key]? then return @props[key] else return null

    ###
    @description Sets a custom property
    @param {string} key The property key
    @param {mixed} val The property value
    @returns {object} the component instance
    ###
    set: (key, val) =>
        @props[key] = val
        return @

    ###
    @description Returns a string representation of the component in the form Component<name>
    @returns {string}
    ###
    toString: =>
        return "Component<#{@name}>"

    ###
    @description Gets a custom property
    @param {string} key The property key
    @returns {mixed} The value
    ###
    val: (v) =>
        @value = v if v?
        return @value

module.exports = Component