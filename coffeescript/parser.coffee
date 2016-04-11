class Parser
  constructor: ->
    @events = []

  @newEvent = ->
    { events: [], actions: [], effects: [], commands: [] }

  @parse = (lines) ->
    state = 
      indent: 0
      events: []

    for line in lines
      @parseLine(line, state)

    state.events

  @parseAtts = (line) ->
    atts = {}
    for attrSet in line.split(' ')
      [attrName, attrVals] = attrSet.split('=')
      attrName = attrName[1..] if attrName[0] is '$'
      atts[attrName] = attrVals.split('|').sample()

    atts

  @parseLine = (line, state) ->
    # remove comments
    commentIdx = line.indexOf('#')
    line = line[...commentIdx] if commentIdx > -1

    [spaces, line] = Parser.extract(line)

    return if line.length == 0

    peek = line[0]
    rest = line[1..].trim()

    if spaces < state.indent
      state.stack.pop()

    if spaces == 0
      evt = Parser.newEvent()
      evt.id = line
      
      state.stack = [{spaces:0, evt:evt}]
      state.events.push(evt)

    else if peek is '-'
      @parseRef(rest, spaces, 'events', state)

    else if peek is '?'
      @parseRef(rest, spaces, 'actions', state)

    else if peek is '@'
      @parseRef(rest, spaces, 'effects', state)

    else if peek is ':'
      args = rest.split(' ').map((arg) -> arg.trim())
      state.stack.last().evt.commands.push(op:args[0], arg:args[1..].join(' '))

    else
      evt = state.stack.last().evt
      evt.actionText = evt.text unless evt.actionText?
      evt.text = line

    state.indent = spaces

  @parseRef = (line, spaces, collection, state) ->
    if spaces == state.stack.last().spaces
      state.stack.pop()

    if line[0] is '>'
      evt = line[1..].trim()
      state.stack.last().evt[collection].push({ref:evt})
      
    else
      evt = Parser.newEvent()
      state.stack.last().evt[collection].push(evt)

      state.stack.push(spaces:spaces, evt:evt)
      
      if collection is 'actions'
        evt.actionText = line
      else
        evt.text = line

  @extract = (line) ->
    spaces = 0
    line = line.replace('\t', '  ')

    while line[0] is ' '
      spaces += 1
      line = line[1..]

    [spaces, line.trim()]

# ------------------export---------------------------

root = exports ? window
root.Parser = Parser
