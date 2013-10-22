class utils
    @ansi:
        reset:      '\u001b[0m'
        end:        '\u001b[0m'
        bold:       '\u001b[1m'
        italic:     '\u001b[3m'
        underline:  '\u001b[4m'
        blink:      '\u001b[5m'
        black:      '\u001b[30m'
        red:        '\u001b[31m'
        green:      '\u001b[32m'
        yellow:     '\u001b[33m'
        blue:       '\u001b[34m'
        magenta:    '\u001b[35m'
        cyan:       '\u001b[36m'
        white:      '\u001b[37m'

    @log: =>
        args = ['[LOG] ']
        args.push i for i in arguments
        console.log.apply(this, args)

    @warn: =>
        args = ['[WARN] ']
        args.push i for i in arguments
        console.warn.apply(this, args)

    @error: =>
        args = ['[ERROR] ']
        args.push i for i in arguments
        console.error.apply(this, args)

    @colorize: (str, name) =>
        str = str.toString() if str.toString?
        # console.log 'adding color', str, name, @
        if @ansi[name]? then return @ansi[name] + str + @ansi.end else return str

    @extend: (object, properties) =>
        for key, val of properties
            object[key] = val
        return object

    @filter: (object, callback) =>
        type = @type(object)
        if type is 'object'
            result = {}
            for k,v of object
                result[k] = v if callback(k, v) is true
            return result
        else if type is 'array'
            return (v for v, i in object when callback(v) is true)

    @first: (object) =>
        return object[0] if object.length?
        if @type(object) is 'object'
            for k,v of object
                return v
        else
            return object

    @keys: (object) =>
        if @type(object) is 'object'
            return (k for k of object)
        return null

    @microtime: =>
        return new Date().getTime();

    @len: (object) =>
        return object.length if object.length?
        if @type(object) is 'object'
            return @keys(object).length
        else
            return null

    @rand: (min, max) =>
        return Math.floor(Math.random() * (max - min + 1)) + min

    @type: (obj) =>
        if obj is undefined or obj is null
            return String obj
        classToType = new Object
        for name in "Boolean Number String Function Array Date RegExp".split(" ")
            classToType["[object " + name + "]"] = name.toLowerCase()
        myClass = Object.prototype.toString.call obj
        if myClass of classToType
            return classToType[myClass]
        return "object"

module.exports = utils
