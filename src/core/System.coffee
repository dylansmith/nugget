utils = require '../utils'

class System
    tickInterval: 1000
    timer: null

    ###
    @constructor
    ###
    constructor: (@name) ->

    ###
    @description Tears down the system
    ###
    dispose: =>

    ###
    @description Registration hook
    ###
    onRegister: =>

    ###
    @description Starts the system loop
    ###
    start: =>
        if @timer
            utils.warn("#{@name} is already started")
        else
            utils.log("#{@name} has started")
            @timer = setInterval(@tick, @tickInterval)
            @tick()

    ###
    @description Stops the system loop
    ###
    stop: =>
        unless @timer
            utils.warn("#{@name} is already stopped")
        else
            clearInterval(@timer)
            @timer = null
            utils.log("#{@name} has stopped")

    ###
    @description The code which is run each iteration of the system loop
    ###
    tick: =>
        utils.log("#{@name} tick!")

    ###
    @description Returns a string representation of the system in the form System<name>
    @returns {string}
    ###
    toString: =>
        return "System<#{@name}>"

module.exports = System