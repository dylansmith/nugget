chai = require 'chai'
chai.should()

# imports
SystemManager = require '../../src/core/SystemManager'
Component = require '../../src/core/System'

# scope container
$ = {}

describe 'SystemManager', ->

    describe '#addSystem', ->

        it 'should throw if a system is not provided'
        it 'should throw if the system is not valid'
        it 'should add the system'

    describe '#dispose', ->

        it 'should tear down all managed system instances'

    describe '#getSystem', ->

        it 'should throw if a system name is not provided'
        it 'should throw if the system name is not valid'
        it 'should return a system instance'

    describe '#hasSystem', ->

        it 'should throw if a system name is not provided'
        it 'should throw if the system name is not valid'
        it 'should return a boolean'

    describe '#removeSystem', ->

        it 'should throw if a system name is not provided'
        it 'should throw if the system name is not valid'
        it 'should remove the system'

    describe '#startSystem', ->

        it 'should throw if a system name is not provided'
        it 'should throw if the system name is not valid'
        it 'should start the system'

    describe '#stopSystem', ->

        it 'should throw if a system name is not provided'
        it 'should throw if the system name is not valid'
        it 'should stop the system'
