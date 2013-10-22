chai = require 'chai'
chai.should()

# imports
EntityManager = require '../../src/core/EntityManager'
Entity = require '../../src/core/Entity'
Component = require '../../src/core/Component'
DuplicateComponentError = require '../../src/exceptions/DuplicateComponentError'
InvalidParamError = require '../../src/exceptions/InvalidParamError'
MissingParamError = require '../../src/exceptions/MissingParamError'
NotFoundError = require '../../src/exceptions/NotFoundError'

# scope container
$ = {}

describe 'EntityManager', ->

    it 'should be a class that allows instantiation', ->
        em = new EntityManager()
        em.constructor.should.equal(EntityManager)

    it 'toId should resolve an object id', ->
        em = new EntityManager()
        em.toId({id: 'testId'}).should.equal('testId')
        em.toId('testId').should.equal('testId')

    describe 'creation', ->

        beforeEach ->
            $.em = new EntityManager()

        describe '#createEntity', ->

            it 'should create a new Entity instance with an id', ->
                e1 = $.em.createEntity()
                e1.constructor.should.equal(Entity)
                e1.id.should.not.be.empty

            it 'should create entities with unique ids', ->
                e1 = $.em.createEntity()
                e2 = $.em.createEntity()
                e1.id.should.not.equal(e2.id)

            it 'should create sequential ids if id is not specified', ->
                for i in [1..15]
                    e = $.em.createEntity()
                    e.id.should.equal("entity_#{i}")

        describe '#createComponent', ->

            it 'should throw if a component name is not provided', ->
                fn = -> $.em.createComponent()
                fn.should.throw(MissingParamError('Expects a component name'))

            it 'should return a Component instance with the provided name', ->
                c1 = $.em.createComponent('Component1')
                c1.constructor.should.equal(Component)

    describe 'registration', ->

        beforeEach ->
            $.em = new EntityManager()

        describe '#registerEntity', ->

            it 'should throw if an entity instance is not provided', ->
                fn = -> $.em.registerEntity()
                fn.should.throw(InvalidParamError, 'Expects an entity instance')

            it 'should throw if an invalid entity instance is provided', ->
                fn = -> $.em.registerEntity('NOPE')
                fn.should.throw(InvalidParamError, 'Expects an entity instance')

            it 'should accept a valid entity', ->
                e1 = $.em.createEntity()
                $.em.removeEntity(e1)
                $.em.hasEntity(e1).should.be.false
                $.em.registerEntity(e1)
                $.em.hasEntity(e1).should.be.true

    describe 'assignment', ->

        describe '#addComponent', ->

            beforeEach ->
                $.em = new EntityManager()
                $.e1 = $.em.createEntity()
                $.c1 = $.em.createComponent('Component1')

            it 'should throw if an entity is not provided', ->
                fn = -> $.em.addComponent()
                fn.should.throw(MissingParamError, 'Expects an entity instance or id')

            it 'should throw if the entity is not found', ->
                fn = -> $.em.addComponent('NOPE', $.c1)
                fn.should.throw(NotFoundError, 'Entity<NOPE> not found')

            it 'should throw if a component is not provided', ->
                fn = -> $.em.addComponent($.e1)
                fn.should.throw(MissingParamError, 'Expects a component instance')

            it 'should throw if the component instance is invalid', ->
                fn = -> $.em.addComponent($.e1.id, Component)
                fn.should.throw(InvalidParamError, 'Not a valid component instance')

            it 'should not add a duplicate component', ->
                $.em.hasComponent($.e1, 'Component1').should.be.false
                $.em.addComponent($.e1, $.c1)
                $.em.hasComponent($.e1, 'Component1').should.be.true
                fn = -> $.em.addComponent($.e1, $.c1)
                fn.should.throw(DuplicateComponentError, "Entity<#{$.e1.id}> already has Component<Component1>")

    describe 'retrieval, inspection and removal', ->

        beforeEach ->
            $.em = new EntityManager()
            $.e1 = $.em.createEntity()                  # multiple components
            $.e2 = $.em.createEntity()                  # single component
            $.e3 = $.em.createEntity()                  # no components
            $.c1 = $.em.createComponent('Component1')   # assigned multiple
            $.c2 = $.em.createComponent('Component2')   # assigned multiple
            $.c3 = $.em.createComponent('Component3')   # assigned single
            $.c4 = $.em.createComponent('Component4')   # not assigned
            $.em.addComponent($.e1, $.c1)
            $.em.addComponent($.e1, $.c2)
            $.em.addComponent($.e2, $.c3)
            #console.log($.em.entityMap)

        describe '#getComponent', ->

            it 'should throw if an entity is not provided', ->
                fn = -> $.em.getComponent()
                fn.should.throw(MissingParamError, 'Expects an entity instance or id')

            it 'should throw if the entity is not found', ->
                fn = -> $.em.getComponent('NOPE')
                fn.should.throw(NotFoundError, "Entity<NOPE> not found")

            it 'should throw if a component name is not provided', ->
                fn = -> $.em.getComponent($.e1)
                fn.should.throw(MissingParamError, 'Expects a component name')

            it 'should throw if a component instance is provided', ->
                fn = -> $.em.getComponent($.e1, $.c1)
                fn.should.throw(InvalidParamError, 'Expects a component name, not a Component instance')

            it 'should throw if the component is not found', ->
                fn = -> $.em.getComponent($.e1, 'NOPE')
                fn.should.throw(NotFoundError, "Component<NOPE> not found for Entity<#{$.e1.id}>")

            it 'should return the component', ->
                $.em.getComponent($.e1, 'Component1').should.equal($.c1)

        describe '#getComponents', ->

            it 'should throw if an entity is not provided', ->
                fn = -> $.em.getComponents()
                fn.should.throw(MissingParamError, 'Expects an entity instance or id')

            it 'should throw if the entity is not found', ->
                fn = -> $.em.getComponents('NOPE', 'Component1')
                fn.should.throw(NotFoundError, "Entity<NOPE> not found")

            it 'should return an empty hash if no components are found', ->
                components = $.em.getComponents($.e3)
                components.should.be.an('object').and.be.empty

            it 'should return all the associated components in a hash, keyed by component name', ->
                # test e1
                components = $.em.getComponents($.e1)
                components.should.be.an('object').and.not.be.empty
                components.should.have.keys(['Component1', 'Component2'])
                components.should.not.have.keys(['Component3'])
                components['Component1'].constructor.should.equal(Component)
                components['Component2'].constructor.should.equal(Component)
                # test e2
                components = $.em.getComponents($.e2)
                components.should.be.an('object').and.not.be.empty
                components.should.have.keys(['Component3'])
                components.should.not.have.keys(['Component1', 'Component2'])
                components['Component3'].constructor.should.equal(Component)

        describe '#getEntitiesByComponent', ->

            it 'should throw if the component name is not provided', ->
                fn = -> $.em.getEntitiesByComponent()
                fn.should.throw(MissingParamError, 'Expects a component name')

            it 'should return an empty hash if no entities are found', ->
                entities = $.em.getEntitiesByComponent('Component4')
                entities.should.be.an('object').and.be.empty

            it 'should return a hash of entities, keyed by the entity id', ->
                entities = $.em.getEntitiesByComponent('Component3')
                entities.should.be.an('object').and.not.be.empty
                for k,v in entities
                    v.constructor.should.equal(Entity)

        describe '#getEntitiesByComponents', ->

            it 'should throw if the list of component names is not provided', ->
                fn = -> $.em.getEntitiesByComponents()
                fn.should.throw(MissingParamError, 'Expects an array of component names')

            it 'should return an empty hash if no entities are found', ->
                entities = $.em.getEntitiesByComponents(['Component4'])
                entities.should.be.an('object').and.be.empty

            it 'should return a hash of entities, keyed by the entity id', ->
                entities = $.em.getEntitiesByComponents(['Component1', 'Component3'])
                entities.should.be.an('object').and.not.be.empty
                entities.should.have.keys([$.e1.id, $.e2.id])
                for k,v in entities
                    v.constructor.should.equal(Entity)

        describe '#hasComponent', ->

            it 'should throw if an entity is not provided', ->
                fn = -> $.em.hasComponent()
                fn.should.throw(MissingParamError, 'Expects an entity instance or id')

            it 'should throw if the entity is not found', ->
                fn = -> $.em.hasComponent('NOPE', 'Component1')
                fn.should.throw(NotFoundError, "Entity<NOPE> not found")

            it 'should throw if a component name is not provided', ->
                fn = -> $.em.hasComponent($.e1)
                fn.should.throw(MissingParamError('Expects a component name'))

            it 'should throw if provided a component instance instead of a component name', ->
                fn = -> $.em.hasComponent($.e1, $.c1)
                fn.should.throw(InvalidParamError('Expects a component name, not a Component instance'))
                fn = -> $.em.hasComponent($.e1, $.c1.name)
                fn.should.not.throw

            it 'should return a boolean', ->
                $.em.hasComponent($.e1, 'Component1').should.be.true
                $.em.hasComponent($.e1, 'Component2').should.be.true
                $.em.hasComponent($.e1, 'Component3').should.be.false
                $.em.hasComponent($.e1, 'Component4').should.be.false
                $.em.hasComponent($.e2, 'Component3').should.be.true

        describe '#hasAllComponents', ->

            it 'should throw if an entity is not provided', ->
                fn = -> $.em.hasAllComponents()
                fn.should.throw(MissingParamError, 'Expects an entity instance or id')

            it 'should throw if the entity is not found', ->
                fn = -> $.em.hasAllComponents('NOPE', 'Component1')
                fn.should.throw(NotFoundError, "Entity<NOPE> not found")

            it 'should throw if the 2nd argument is not an array', ->
                fn = -> $.em.hasAllComponents($.e1)
                fn.should.throw(InvalidParamError, 'Expects an array of component names')

            it 'should return a boolean', ->
                $.em.hasAllComponents($.e1, ['Component1', 'Component2']).should.be.true
                $.em.hasAllComponents($.e1, ['Component2', 'Component3']).should.be.false

        describe '#hasAnyComponents', ->

            it 'should throw if an entity is not provided', ->
                fn = -> $.em.hasAnyComponents()
                fn.should.throw(MissingParamError, 'Expects an entity instance or id')

            it 'should throw if the entity is not found', ->
                fn = -> $.em.hasAnyComponents('NOPE', 'Component1')
                fn.should.throw(NotFoundError, "Entity<NOPE> not found")

            it 'should throw if the 2nd argument is not an array', ->
                fn = -> $.em.hasAnyComponents($.e1)
                fn.should.throw(InvalidParamError, 'Expects an array of component names')

            it 'should return a boolean', ->
                $.em.hasAnyComponents($.e1, ['Component1', 'Component3']).should.be.true
                $.em.hasAnyComponents($.e1, ['Component2', 'Component3']).should.be.true
                $.em.hasAnyComponents($.e1, ['Component3', 'Component4']).should.be.false

        describe '#hasEntity', ->

            it 'should return a boolean', ->
                valid = [$.e1, $.e2, $.e3]
                $.em.hasEntity('NOPE').should.be.false
                $.em.hasEntity(e).should.be.true for e in valid

        describe '#removeComponent', ->

            it 'should throw if an entity is not provided', ->
                fn = -> $.em.removeComponent()
                fn.should.throw(MissingParamError, 'Expects an entity instance or id')

            it 'should throw if the entity is not found', ->
                fn = -> $.em.removeComponent('NOPE', 'Component1')
                fn.should.throw(NotFoundError, 'Entity<NOPE> not found')

            it 'should throw if the component name is not provided', ->
                fn = -> $.em.removeComponent($.e1)
                fn.should.throw(MissingParamError, 'Expects a component name')

            it 'should remove only the specified component from the entity', ->
                $.em.hasComponent($.e1, 'Component1').should.be.true
                $.em.hasComponent($.e1, 'Component2').should.be.true
                $.em.removeComponent($.e1, 'Component1')
                $.em.hasComponent($.e1, 'Component1').should.be.false
                $.em.hasComponent($.e1, 'Component2').should.be.true

            it 'should return the removed component', ->
                component = $.em.removeComponent($.e1, 'Component1')
                component.should.be.an('object')
                component.name.should.equal('Component1')

        describe '#removeEntity', ->

            it 'should throw if an entity is not provided', ->
                fn = -> $.em.removeEntity()
                fn.should.throw(MissingParamError, 'Expects an entity instance or id')

            it 'should throw if the entity is not found', ->
                fn = -> $.em.removeEntity('NOPE')
                fn.should.throw(NotFoundError, 'Entity<NOPE> not found')

            it 'should remove the entity', ->
                $.em.hasEntity($.e1.id).should.be.true
                $.em.removeEntity($.e1.id)
                $.em.hasEntity($.e1.id).should.be.false

            it 'should remove any component associations', ->
                components = ['Component1', 'Component2']
                $.em.hasAllComponents($.e1.id, components).should.be.true
                $.em.removeEntity($.e1.id)
                fn = -> $.em.getComponents($.e1)
                fn.should.throw(NotFoundError, "Entity<#{$.e1.id}> not found")

            it 'should clean up the internal maps', ->
                components = ['Component1', 'Component2']
                $.em.removeEntity($.e1.id)
                # the entity map should have no entry
                $.em.entityMap.should.not.have.keys($.e1.id)
                # the entity id should have been removed from each component in the componentMap
                for c in components
                    $.em.componentMap[c].should.exist
                    $.em.componentMap[c].by_entity.should.not.have.keys($.e1.id)

        describe '#removeAllEntities', ->

            it 'should remove all entities', ->
                entities = [$.e1, $.e2, $.e3]
                $.em.hasEntity(e).should.be.true for e in entities
                $.em.removeAllEntities()
                $.em.hasEntity(e).should.be.false for e in entities
