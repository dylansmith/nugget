chai = require 'chai'
chai.should()
expect = chai.expect()

nugget = require '../src/nugget'
Component = require '../src/core/Component'
Entity = require '../src/core/Entity'
System = require '../src/core/System'
EntityManager = require '../src/core/EntityManager'
SystemManager = require '../src/core/SystemManager'
World = require '../src/core/World'
config = require '../src/config'
utils = require '../src/utils'

describe 'The nugget namespace', ->

    it 'should have a Component class', ->
        nugget.Component.should.equal(Component)

    it 'should have a System class', ->
        nugget.System.should.equal(System)

    it 'should have an Entity class', ->
        nugget.Entity.should.equal(Entity)

    it 'should have an EntityManager class', ->
        nugget.EntityManager.should.equal(EntityManager)

    it 'should have a SystemManager class', ->
        nugget.SystemManager.should.equal(SystemManager)

    it 'should have a World class', ->
        nugget.World.should.equal(World)

    it 'should have a config object', ->
        nugget.config.should.equal(config)

    it 'should have a utils object', ->
        nugget.utils.should.equal(utils)

    it 'should cause polyfills to be applied', ->
        String.prototype.trim.should.be.a('function')
        String.prototype.ltrim.should.be.a('function')
        String.prototype.rtrim.should.be.a('function')
        String.prototype.strip.should.be.a('function')
        Array.prototype.filter.should.be.a('function')
