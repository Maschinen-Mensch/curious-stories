class Parser
  constructor: ->
    @events = []

  @newEvent = ->
    { events: [], actions: [] }

  @parse = (lines) ->
    state = 
      indent: 0
      events: []

    for line in lines
      @parseLine(line, state)

    state.events

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

    else if peek is ':'
      args = rest.split(' ').map((arg) -> arg.trim())
      state.stack.last().evt[args[0]] = args[1]

    else
      evt = state.stack.last().evt
      evt.text = line
      evt.actionText = line unless evt.actionText?

    state.indent = spaces

  @parseRef = (line, spaces, collection, state) ->
    if spaces == state.stack.last().spaces
      state.stack.pop()

    if line[0] is '>'
      evt = line[1..].trim()
      state.stack.last().evt[collection].push(evt)
      
    else
      evt = Parser.newEvent()
      state.stack.last().evt[collection].push(evt)

      state.stack.push(spaces:spaces, evt:evt)
      evt.actionText = evt.text = line

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
