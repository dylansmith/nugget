chai = require 'chai'
chai.should()

# imports
config = require '../../src/config'
EntityManager = require '../../src/core/EntityManager'
Entity = require '../../src/core/Entity'
Component = require '../../src/core/Component'
DuplicateComponentError = require '../../src/exceptions/DuplicateComponentError'
InvalidParamError = require '../../src/exceptions/InvalidParamError'
MissingParamError = require '../../src/exceptions/MissingParamError'
NotFoundError = require '../../src/exceptions/NotFoundError'

config.debugging = false

# scope container
$ = {}

describe 'Entity', ->

    beforeEach ->
        $.em = new EntityManager()

    describe 'construction', ->

        it 'should throw if an EntityManager instance is not provided', ->
            fn = -> e1 = new Entity()
            fn.should.throw(MissingParamError, 'Expects an EntityManager instance')

        it 'should throw if the 1st argument is not an EntityManager instance', ->
            fn = -> e1 = new Entity({})
            fn.should.throw(InvalidParamError, 'Not a valid EntityManager instance')

        it 'should generate an id if one is not provided', ->
            e1 = new Entity($.em)
            e1.id.should.exist.and.not.be.empty

        it 'should use the id if one is provided', ->
            e1 = new Entity($.em, 'custom_id')
            e1.id.should.equal('custom_id')

        it 'should not allow duplicate custom ids to be created', ->
            e1 = new Entity($.em, 'custom_id')
            e1.id.should.equal('custom_id')
            fn = -> e2 = new Entity($.em, 'custom_id')
            fn.should.throw(InvalidParamError, "Entity<custom_id> is already registered with this EntityManager")

    describe '#add', ->

        beforeEach ->
            $.e1 = new Entity($.em)

        it 'should throw if the component name is not provided', ->
            fn = -> $.e1.add()
            fn.should.throw(MissingParamError, 'Expects a component name')

        it 'should add the component to the entity', ->
            $.e1.has('Component1').should.be.false
            $.e1.has('Component2').should.be.false
            $.e1.add('Component1')
            $.e1.has('Component1').should.be.true
            $.e1.has('Component2').should.be.false

        it 'should throw if the component already exists', ->
            $.e1.add('Component1')
            fn = -> $.e1.add('Component1')
            fn.should.throw(DuplicateComponentError, "Entity<#{$.e1.id}> already has Component<Component1>")

    describe 'components', ->

        beforeEach ->
            $.e1 = $.em.createEntity()      # multiple components
            $.e2 = $.em.createEntity()      # single component
            $.e3 = $.em.createEntity()      # no components
            $.c1 = $.e1.add('Component1')   # assigned multiple
            $.c2 = $.e1.add('Component2')   # assigned multiple
            $.c3 = $.e2.add('Component3')   # assigned single
            $.components = [$.c1, $.c2, $.c3]

        describe '#get', ->

            it 'should throw if the component name is not provided', ->
                fn = -> $.e1.get()
                fn.should.throw(MissingParamError, 'Expects a component name')

            it 'should throw if the component name is not found', ->
                fn = -> $.e1.get('NOPE')
                fn.should.throw(NotFoundError, "Component<NOPE> not found for Entity<#{$.e1.id}>")

            it 'should return the component instance if found', ->
                c1 = $.e1.get('Component1')
                c1.name.should.equal('Component1')

        describe '#getAll', ->

            it 'should return an empty hash if no components are found', ->
                components = $.e3.getAll()
                components.should.be.an('object').and.be.empty

            it 'should return all the associated components in a hash, keyed by component name', ->
                # test e1
                components = $.e1.getAll()
                components.should.be.an('object').and.not.be.empty
                components.should.have.keys(['Component1', 'Component2'])
                components.should.not.have.keys(['Component3'])
                components['Component1'].should.be.an.instanceof(Component)
                components['Component2'].should.be.an.instanceof(Component)
                # test e2
                components = $.e2.getAll()
                components.should.be.an('object').and.not.be.empty
                components.should.have.keys(['Component3'])
                components.should.not.have.keys(['Component1', 'Component2'])
                components['Component3'].should.be.an.instanceof(Component)

        describe '#has', ->

            it 'should throw if a component name is not provided', ->
                fn = -> $.e1.has()
                fn.should.throw(MissingParamError('Expects a component name'))

            it 'should throw if provided a component instance instead of a component name', ->
                fn = -> $.e1.has($.c1)
                fn.should.throw(InvalidParamError('Expects a component name, not a Component instance'))
                fn = -> $.e1.has($.c1.name)
                fn.should.not.throw

            it 'should return a boolean', ->
                $.e1.has('Component1').should.be.true
                $.e1.has('Component2').should.be.true
                $.e1.has('Component3').should.be.false
                $.e2.has('Component1').should.be.false
                $.e2.has('Component2').should.be.false
                $.e2.has('Component3').should.be.true

        describe '#hasAll', ->

            it 'should throw if the 1st argument is not an array', ->
                fn = -> $.e1.hasAll('Component1')
                fn.should.throw(InvalidParamError, 'Expects an array of component names')

            it 'should return a boolean', ->
                $.e1.hasAll(['Component1', 'Component2']).should.be.true
                $.e1.hasAll(['Component2', 'Component3']).should.be.false
                $.e2.hasAll(['Component3']).should.be.true

        describe '#remove', ->

            it 'should throw if the component name is not provided', ->
                fn = -> $.e1.remove()
                fn.should.throw(MissingParamError, 'Expects a component name')

            it 'should remove only the specified component from the entity', ->
                $.e1.has('Component1').should.be.true
                $.e1.has('Component2').should.be.true
                $.e1.remove('Component1')
                $.e1.has('Component1').should.be.false
                $.e1.has('Component2').should.be.true

            it 'should return the removed component', ->
                component = $.e1.remove('Component1')
                component.should.be.an('object')
                component.name.should.equal('Component1')
