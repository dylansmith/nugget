require '../src/polyfills'

nugget =
    Component: require('./core/Component')
    System: require('./core/System')
    Entity: require('./core/Entity')
    EntityManager: require('./core/EntityManager')
    SystemManager: require('./core/SystemManager')
    World: require('./core/World')
    config: require('./config')
    utils: require('./utils')

module.exports = nugget