chai = require 'chai'
chai.should()
expect = chai.expect

utils = require '../src/utils'
nativeTypes = [
    new Array(),
    new String(),
    new Number(),
    new Object(),
    new Boolean(),
    new Date(),
    new RegExp(),
    new Function()
]
testObj = {one: 1, two: 2, three: 3}
testArray = [0, 1, 2, 3, 'four', false]


describe 'utils', ->

    describe '#extend', ->

        it 'should merge the properties of the 2nd object into the 1st object', ->
            result = utils.extend({foo: 'bar'}, testObj)
            result.should.not.equal(testObj)
            result.foo.should.equal('bar')
            for k,v in testObj
                result[k].should.equal(v)

    describe '#filter', ->

        it 'should filter items from an array if the callback returns true', ->
            excl = [1, 'four', false]
            expected = [0, 2, 3]
            callback = (v) -> excl.indexOf(v) == -1
            result = utils.filter(testArray, callback)
            for v, i in expected
                result[i].should.equal(v) if callback(v) == true

        it 'should filter items from an object if the callback returns true', ->
            callback = (k, v) -> k is 'one' or v is 3
            result = utils.filter(testObj, callback)
            result.should.have.keys(['one', 'three'])

    describe '#first', ->

        it 'should return the first property of an object', ->
            utils.first(testObj).should.equal(1)

        it 'should return the first item of objects that have a length property', ->
            utils.first([0, 1, 2]).should.equal(0)
            utils.first('hello').should.equal('h')

        it 'should return the object otherwise', ->
            tests = [678, true, false, new Date()]
            for i in tests
                expect(utils.first(i)).to.equal(i)

    describe '#keys', ->

        it 'should return null if not an object', ->
            for i in nativeTypes
                unless utils.type(i) is 'object'
                    expect(utils.keys(i)).to.equal(null)

        it 'should return the keys of an object', ->
            keys = utils.keys(testObj)
            for val, i in ['one', 'two', 'three']
                keys[i].should.equal(val)

    describe '#len', ->

        it 'should return the number of properties of an object', ->
            utils.len(testObj).should.equal(3)

        it 'should return the length of objects with a length property', ->
            for obj in nativeTypes
                if 'length' in nativeTypes
                    utils.len(obj).should.equal(obj.length)

        it 'should return null for other types', ->
            for obj in nativeTypes
                if 'length' not in obj and utils.type(obj) is not 'object'
                    expect(utils.len(obj)).to.equal(null)

    describe '#type', ->

        it 'should indentify variable types correctly', ->
            fn = utils.type
            # arrays
            fn([]).should.equal('array')
            fn(new Array()).should.equal('array')
            # objects
            fn({}).should.equal('object')
            fn(new Object()).should.equal('object')
            # strings
            fn('string').should.equal('string')
            fn(new String('string')).should.equal('string')
            # numbers
            fn(1234).should.equal('number')
            fn(1).should.equal('number')
            fn(0).should.equal('number')
            fn(new Number(1234)).should.equal('number')
            # booleans
            fn(false).should.equal('boolean')
            fn(true).should.equal('boolean')
            fn(new Boolean()).should.equal('boolean')
            # date
            fn(new Date()).should.equal('date')
            # regexp
            fn(new RegExp('.*', 'i')).should.equal('regexp')
            fn(/.*/i).should.equal('regexp')
            # functions
            fn(new Function()).should.equal('function')
            fn(->).should.equal('function')
            fn(=>).should.equal('function')
