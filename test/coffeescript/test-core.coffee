describe 'Parser', ->
  parse = (txt) ->
    Parser.parse(txt.split('\n'))[0]

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
    events[0].events.length.should.be.eql(2)

    events[0].events[0].ref.should.be.eql('next1')
    events[0].events[1].ref.should.be.eql('next2')

  it 'parseEvents2', ->
    events = parse('start1\n  -> next1\n\nstart2\n  -> next2')

    events.length.should.be.eql(2)
    events[0].id.should.be.eql('start1')
    events[0].events.length.should.be.eql(1)
    events[0].events[0].ref.should.be.eql('next1')

    events[1].id.should.be.eql('start2')
    events[1].events.length.should.be.eql(1)
    events[1].events[0].ref.should.be.eql('next2')

  # it 'parseEvents3', ->
  #   events = parse('start\n  -2> next1\n  -3 next2')
  #   events.length.should.be.eql(1)
  #   events[0].events[0].ref.should.be.eql('next1')

  it 'parseActions', ->
    events = parse('start\n  ? act1\n  ? act2')

    events.length.should.be.eql(1)
    events[0].id.should.be.eql('start')
    events[0].actions.length.should.be.eql(2)
    events[0].actions[0].actionText.should.be.eql('act1')
    events[0].actions[1].actionText.should.be.eql('act2')

  it 'parseActions2', ->
    events = parse('start\n  ? act\n    desc')

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
    events[0].actions[0].events[0].ref.should.be.eql('next')

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

    events[1].actions[0].events[0].ref.should.be.eql('next')

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
    events[0].actions[0].ref.should.be.eql('act1')
    events[0].actions[1].ref.should.be.eql('act2')

  it 'parseComment', ->
    events = parse('#')
    events.length.should.be.eql(0)

  it 'parseComment2', ->
    events = parse('start # comment')
    events.length.should.be.eql(1)
    events[0].id.should.be.eql('start')

  it 'parseComment3', ->
    events = parse('start\n  ? act # comment')
    events.length.should.be.eql(1)
    events[0].id.should.be.eql('start')
    events[0].actions[0].actionText.should.be.eql('act')

  it 'parseCommandImage', ->
    events = parse('start\n  desc\n  : image http://cc.com/img.png')
    events.length.should.be.eql(1)
    events[0].id.should.be.eql('start')
    events[0].text.should.be.eql('desc')

    events[0].commands.length.should.be.eql(1)
    events[0].commands[0].op.should.be.eql('image')
    events[0].commands[0].arg.should.be.eql('http://cc.com/img.png')

  it 'parseCommandPartyFlags', ->
    events = parse('start\n  desc\n  :reqPartyFlags +rope\n  :reqPartyFlags -rope')

    events.length.should.be.eql(1)
    events[0].id.should.be.eql('start')
    events[0].text.should.be.eql('desc')

    events[0].commands.length.should.be.eql(2)
    events[0].commands[0].op.should.be.eql('reqPartyFlags')
    events[0].commands[1].op.should.be.eql('reqPartyFlags')

  it 'parseEffects', ->
    events = parse('start\n  @ hello')

    events.length.should.be.eql(1)
    events[0].id.should.be.eql('start')
    events[0].effects.length.should.be.eql(1)
    events[0].effects[0].text.should.be.eql('hello')

  # it 'parseEffects2', ->
  #   events = parse('start\n  @ hello\n  desc')

  #   events.length.should.be.eql(1)
  #   events[0].id.should.be.eql('start')
  #   events[0].text.should.be.eql('desc')
  #   events[0].effects.length.should.be.eql(1)
  #   events[0].effects[0].text.should.be.eql('hello')

  it 'parseAtts', ->
    atts = Parser.parseAtts('$name=Bob')
    atts.name.should.be.eql('Bob')

    atts = Parser.parseAtts('name=Rob')
    atts.name.should.be.eql('Rob')

    atts = Parser.parseAtts('name=Hans|Hans')
    atts.name.should.be.eql('Hans')

    atts = Parser.parseAtts('name=Hans|Hans job=Coder')
    atts.name.should.be.eql('Hans')
    atts.job.should.be.eql('Coder')

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

  it 'parseAtts', ->
    TextHelper.replaceAtts('That $name', {name:'foo'}).should.be.eql('That foo')

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

