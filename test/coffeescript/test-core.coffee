describe 'Parser', ->
  parse = (txt) ->
    Parser.parse(txt.split('\n'))

  it 'parseEventSimple', ->
    events = parse('start')

    events.length.should.be.eql(1)
    events[0].id.should.be.eql('start')

  it 'parseEventSimple2', ->
    events = parse('start\n  desc')

    events.length.should.be.eql(1)
    events[0].id.should.be.eql('start')
    events[0].text.should.be.eql('desc')

  it 'parseEventSimple3', ->
    events = parse('start\n  ques\n  desc')

    events.length.should.be.eql(1)
    events[0].id.should.be.eql('start')
    events[0].actionText.should.be.eql('ques')
    events[0].text.should.be.eql('desc')    

  it 'parseEvents', ->
    events = parse('start\n  -> next1\n  - > next2')

    events.length.should.be.eql(1)
    events[0].id.should.be.eql('start')
    events[0].events.should.be.eql(['next1', 'next2'])

  it 'parseEvents2', ->
    events = parse('start1\n  -> next1\n\nstart2\n  -> next2')

    events.length.should.be.eql(2)
    events[0].id.should.be.eql('start1')
    events[0].events.length.should.be.eql(1)
    events[0].events[0].should.be.eql('next1')
    events[1].id.should.be.eql('start2')
    events[1].events.length.should.be.eql(1)
    events[1].events[0].should.be.eql('next2')

  it 'parseActions', ->
    lines = ['start', '  ? act1', '  ? act2']
    events = Parser.parse(lines)

    events.length.should.be.eql(1)
    events[0].id.should.be.eql('start')
    events[0].actions.length.should.be.eql(2)
    events[0].actions[0].actionText.should.be.eql('act1')
    events[0].actions[1].actionText.should.be.eql('act2')

  it 'parseActions2', ->
    lines = ['start', '  ? act', '    desc']
    events = Parser.parse(lines)

    events.length.should.be.eql(1)
    events[0].id.should.be.eql('start')
    events[0].actions.length.should.be.eql(1)
    events[0].actions[0].actionText.should.be.eql('act')
    events[0].actions[0].text.should.be.eql('desc')

  it 'parseActions3', ->
    events = parse('start\n  ? act1\n    desc1\n  ? act2\n    desc2')

    events.length.should.be.eql(1)
    events[0].id.should.be.eql('start')
    events[0].actions.length.should.be.eql(2)

    events[0].actions[0].actionText.should.be.eql('act1')
    events[0].actions[0].text.should.be.eql('desc1')

    events[0].actions[1].actionText.should.be.eql('act2')
    events[0].actions[1].text.should.be.eql('desc2')

  it 'parseActions4', ->
    events = parse('start\n  desc\n  ? act')

    events.length.should.be.eql(1)
    events[0].id.should.be.eql('start')
    events[0].text.should.be.eql('desc')
    events[0].actions.length.should.be.eql(1)
    events[0].actions[0].actionText.should.be.eql('act')

  it 'parseActionsDeep', ->
    events = parse('start\n  ? act\n    desc\n    ->next')

    events.length.should.be.eql(1)
    events[0].id.should.be.eql('start')

    events[0].actions[0].actionText.should.be.eql('act')
    events[0].actions[0].text.should.be.eql('desc')

    events[0].actions[0].events.length.should.be.eql(1)
    events[0].actions[0].events[0].should.be.eql('next')

  it 'parseActionsDeep2', ->
    events = parse('start\n  - next1\n    -next2\n      -  next3')

    events.length.should.be.eql(1)
    events[0].id.should.be.eql('start')
    events[0].events[0].text.should.be.eql('next1')
    events[0].events[0].events[0].text.should.be.eql('next2')
    events[0].events[0].events[0].events[0].text.should.be.eql('next3')

  it 'parseActionsEventInline', ->
    events = parse('start\n  - next\n    ? act1\n    ? act2')

    events.length.should.be.eql(1)
    events[0].id.should.be.eql('start')
    events[0].events[0].text.should.be.eql('next')
    events[0].events[0].actions.length.should.be.eql(2)
    events[0].events[0].actions[0].actionText.should.be.eql('act1')
    events[0].events[0].actions[1].actionText.should.be.eql('act2')

  it 'parseActionsEventInline2', ->
    events = parse('start\nstart2\n  ? act1\n     ->next\n  ? act2')

    events.length.should.be.eql(2)
    events[0].id.should.be.eql('start')
    events[1].id.should.be.eql('start2')

    events[0].actions.length.should.be.eql(0)

    events[1].actions[0].actionText.should.be.eql('act1')
    events[1].actions[1].actionText.should.be.eql('act2')

    events[1].actions[0].events[0].should.be.eql('next')

  it 'parseActionsEventInline3', ->
    events = parse('start\n  ? act1\n    - next\n  ? act2')

    events.length.should.be.eql(1)
    events[0].id.should.be.eql('start')
    events[0].actions.length.should.be.eql(2)

  it 'parseActionRef', ->
    events = parse('start\n  ?> act1\n  ?> act2')

    events.length.should.be.eql(1)
    events[0].id.should.be.eql('start')
    events[0].actions.length.should.be.eql(2)
    events[0].actions[0].should.be.eql('act1')
    events[0].actions[1].should.be.eql('act2')

  it 'extractLine', ->
    Parser.extract('a').should.be.eql([0, 'a'])
    Parser.extract('  a').should.be.eql([2, 'a'])
    Parser.extract('    a').should.be.eql([4, 'a'])

describe 'TextHelper', ->
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

