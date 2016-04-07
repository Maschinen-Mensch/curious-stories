describe 'TextHelper', ->

    create individual tests for small text manipiations

  it 'replaceName', ->
    TextHelper.replaceName('abc def').should.be.eql('abc def')
    TextHelper.replaceName('$name', ['bob', 'rob']).should.be.eql('bob and rob')
    TextHelper.replaceName('$name', ['bob', 'rob', 'riad']).should.be.eql('bob, rob and riad')
    TextHelper.replaceName('$name', ['sara', 'bob', 'rob', 'riad']).should.be.eql('sara, bob, rob and riad')

  it 'parseText', ->
    TextHelper.parse('abc').length.should.eql(3)
    TextHelper.parse('[abc|def]').length.should.eql(3)

describe 'Core', ->
  it 'match', ->
    Core.match('1..', 1).should.be.ok
    Core.match('1..', 5).should.be.ok
    Core.match('..5', 5).should.be.ok
    Core.match('..5', 1).should.be.ok
    Core.match('2..5', 3).should.be.ok

    Core.match('..5', 7).should.not.be.ok
    Core.match('5..', 2).should.not.be.ok 
    Core.match('5..8', 9).should.not.be.ok

    Core.match(5, 5).should.be.ok
    Core.match(9, 5).should.not.be.ok

  it 'match short syntax', ->
    Core.match('1', 1).should.be.ok
    Core.match('1', 2).should.not.be.ok

  it 'checkFlags', ->
    flags = 
      riad:true,
      robert:false,
      coder:true

    Core.checkFlags('+riad', flags).should.be.ok
    Core.checkFlags('-riad', flags).should.not.be.ok
 
    Core.checkFlags('+riad +coder -robert', flags).should.be.ok
    Core.checkFlags('+riad | +robert', flags).should.be.ok
    Core.checkFlags('+riad |   +robert', flags).should.be.ok # white space is ok
    Core.checkFlags('+riad|+robert', flags).should.be.ok
    Core.checkFlags('-robert', flags).should.be.ok
    Core.checkFlags('-riad', flags).should.not.be.ok

    Core.checkFlags({riad:true}, flags).should.be.ok
    Core.checkFlags({riad:false}, flags).should.not.be.ok
    Core.checkFlags([{riad:false}], flags).should.not.be.ok
    Core.checkFlags([{riad:false},{coder:true}], flags).should.be.ok

    Core.checkFlags(false, flags).should.not.be.ok
    Core.checkFlags(true, flags).should.be.ok
    Core.checkFlags({}, flags).should.be.ok
    Core.checkFlags('', flags).should.be.ok

  it 'arrify', ->
    Core.arrify('a').should.eql(['a'])
    Core.arrify(['a']).should.eql(['a'])
    Core.arrify(['a','b']).should.eql(['a','b'])

  it 'arrify with spaces', ->
    Core.arrify('abc def').should.eql(['abc', 'def'])
    Core.arrify('abc def', false).should.not.eql(['abc', 'def'])

