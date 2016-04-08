class Proto
  @getEvent = (id) ->
    return id if Object.isObject(id)
    evt = config.events.find((e) -> e.id is id)
    Core.assert(evt?, "Event with ID #{id} not found")
    evt

class TextHelper
  @replaceName = (text, names=[]) ->
    names = Core.arrify(names)

    nameTxt = ''
    for name, i in names
      if names.length>1 and i == names.length-1
        nameTxt += ' and '

      nameTxt += name

      if i<names.length-2
        nameTxt += ', '

    text = text.replace('$name', nameTxt)

    if names.length > 1
      text = text.replace('$is',  "are")
      text = text.replace('$i',  "we")
      text = text.replace('$I',  "We")
    else
      text = text.replace('$is', "is")
      text = text.replace('$i',  "I")
      text = text.replace('$I',  "I")

    text

  @parse = (txt, gender='male') ->
    if gender is 'female'
      txt = txt.replace('$He',  "She")
      txt = txt.replace('$His', "Her")
      txt = txt.replace('$Him', "Her")
      txt = txt.replace('$he',  "she")
      txt = txt.replace('$his', "her")
      txt = txt.replace('$him', "her")
    else
      txt = txt.replace('$He',  "He")
      txt = txt.replace('$His', "His")
      txt = txt.replace('$Him', "Him")
      txt = txt.replace('$he',  "he")
      txt = txt.replace('$his', "his")
      txt = txt.replace('$him', "him")

    matches = txt.match(/\[.*?\]/g)
    if matches?
      for match in matches
        shortMatch = match[1..-2]
        altTexts = shortMatch.split('|')

        replacement = if altTexts.length > 1
          altTexts.sample()
        else if Math.random() < 0.5
          altTexts[0]
        else
          ''

        txt = txt.replace(match, replacement)

    txt

class Core
  @arrify = (ids, expandString=true) ->
    return [] unless ids?

    if expandString and Object.isString(ids)
      return ids.split(' ')

    if Object.isArray(ids) then ids else [ids]

  @strFlags = (flags) ->
    entries = []
    
    for id, val of flags
      entries.push(id) if val

    entries.join(' ')

  @setFlags = (flagSet, actualFlags={}) ->
    flags = @parseFlags(flagSet).sample()
    Object.merge(actualFlags, flags)

  @parseFlags = (flagSet, prefix='') ->
    # string syntax for flags
    if Object.isString(flagSet)
      orSet = []
      for flagGroup in flagSet.split('|')
        andSet = {}
        for flag in flagGroup.split(' ')
          flag = flag.trim()

          if flag.length > 0
            Core.assert(flag[0] is '+' or flag[0] is '-', "flag #{flag} needs to start with + or -")
            andSet[prefix+flag[1..]] = flag[0] is '+'

        orSet.push(andSet)

      orSet
      
    else
      Core.arrify(flagSet)

  @checkFlags = (flagSet, actualFlags) ->
    if Object.isBoolean(flagSet)
      return flagSet

    flagSet = @parseFlags(flagSet)

    Core.arrify(flagSet).any((reqFlags) ->
      Object.all(reqFlags, (id, val) -> 
        entry = actualFlags[id] ? false
        entry is val
      )
    )

  @parseRange = (range, attributes={}) ->
    parse = (x) -> 
      val = attributes[x]
      return val if val?
      
      val = parseInt(x)
      if not isNaN(val) then val else null

    if Object.isString(range)
      [a, b] = range.split('..')

      if not b?
        xMin = xMax = parse(a)

      else if b[0] is '.'
        xMin = parse(a) ? -10000

        if b.length > 1
          xMax = parse(b[1..]) - 1 ? 10000
        else
          xMax = xMin

      else
        xMin = parse(a) ? -100000
        xMax = parse(b) ?  100000

    else if Object.isArray(range)
      if range.length == 2
        [xMin, xMax] = [range[0], range[1]]

      else if range.length == 1
        [xMin, xMax] = [range[0], range[0]]

      else
        Core.assert(false, "Invalid int range length (#{range.length})")
      
      if xMin > xMax
        temp = xMin
        xMin = xMax
        xMax = temp

    else
      xMin = range
      xMax = range

    [xMin, xMax]

  @randRange = (range) ->
    [xMin, xMax] = @parseRange(range)
    Number.random(xMin, xMax)

  @match = (range, x, attributes = {}) ->
    [xMin, xMax] = @parseRange(range, attributes)
    return xMax >= x >= xMin

  @parseText = (txt) ->
    regex = /(\§\w+)/

    loop
      match = regex.exec(txt)
      break unless match?

      txt = txt.replace(match[1], config.strings[match[1].from(1)].sample())

    txt

  @parseMentions = (txt, entities) ->
    mentions = []

    for i in [0...6]
      if txt.indexOf("$#{i}") > -1
        ent = entities[i]
        secretMention = false

        if txt.indexOf("$#{i}f") > -1
          name = if ent? then ent.firstName else ''
          txt = txt.replace("$#{i}f", name)
          secretMention = true

        if txt.indexOf("$#{i}l") > -1
          name = if ent? then ent.lastName else ''
          txt = txt.replace("$#{i}l", name)
          secretMention = true

        if txt.indexOf("$#{i}i") > -1
          name = if ent? then "#{ent.firstName[0]}. #{ent.lastName[0]}." else ''
          txt = txt.replace("$#{i}i", name)
          secretMention = true

        if not secretMention
          name = if ent? then ent.fullName() else ''
          txt = txt.replace("$#{i}", name)
          mentions.push(ent)

    [txt, mentions]

  @clamp: (val, min, max) ->
    Math.max(Math.min(val, max), min)

  @assert = (exp, message) ->
    if not exp
      console.error(message)
      console.trace()
      debugger

# ------------------export---------------------------

root = exports ? window
root.Core = Core
root.Proto = Proto
root.TextHelper = TextHelper
