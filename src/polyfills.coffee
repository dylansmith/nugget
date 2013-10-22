polyfills = ->
    String::trim = -> @replace /^\s+|\s+$/g, ''
    String::ltrim = -> @replace /^\s+/g, ''
    String::rtrim = -> @replace /\s+$/g, ''
    String::strip = (char) ->
        return @trim unless char?
        return @replace new RegExp("^#{char}+|#{char}+$", 'g'), ''

    unless Array::filter
        Array::filter = (callback) -> element for element in this when callback(element)

polyfills()
module.exports = polyfills
