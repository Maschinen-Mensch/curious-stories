class Story
  constructor: ->
    @reqs = new Requirements(this)
    @effs = new Effects(this)

    @setupExtensions()
    # @startGame()

    $('#game').hide()

  startGame: ->
    try
      # code = "[#{window.firepad.getText()}]"
      # acorn.parse(code)
      # config.events = eval(code)
      code = window.firepad.getText().split('\n')
      config.events = Parser.parse(code)
    catch e
      alert(e.message)
      return

    $('#firepad-container').hide()
    $('#help').hide()
    $('#gameText').empty()
    $('#game').show()

    @partyFlags = {}
    @entities = []

    @showEvent(config.events[0])

  editGame: ->
    $('#game').hide()    
    $('#help').show()    
    $('#firepad-container').show()

  addEntity: ->
    newEntity = new Entity()
    # Object.merge(newEntity, protoEntity)

    protoEntity = config.entities.sample()
    newEntity.name = TextHelper.parse(protoEntity.name)

    for key, val of protoEntity when key[0] is '$'
      newEntity.attributes[key[1..]] = Core.randRange(val) 

    @entities.push(newEntity)

  showEvent: (eventId) ->
    $('#gameText .action').remove()
    $('#gameText p').addClass('old')

    @actions = []
    @doEvent(eventId)

    if @actions.length == 0 # game over
      $('#gameText').append("<p><a class=start href='' onClick='startGame(); return false;'>New Game</a></p>")

  doAction: (actionIdx) ->
    action = @actions[actionIdx]
    @showEvent(action)

  hasRequirements: (eventIn, entity) ->
    event = Proto.getEvent(eventIn)

    for key, val of event
      if key.startsWith('req')
        Core.assert(@reqs[key]?, "Unknown requirement #{key}")

        if not @reqs[key](val, entity)
          console.warn("failed requirement #{key} for event #{event.id ? 'inline'}")
          return false

    if not @doEntityEffects(event.entityEffects, true)
      return false
          
    true

  expandEvent: (def) ->
    if def.ref? # id/slot syntax
      Proto.getEvent(def.ref)
    else if Object.isObject(def) # inline syntax
      def
    else # short id syntax
      Proto.getEvent(def)

  randEvent: (eventSet, ctx) ->
    # check for priority groups in ASCENDING order
    for prio, group of Core.arrify(eventSet).groupBy((e) -> e.prio ? 100)

      # we need to make sure preserve the slots value correctly
      eventSlots = Core.arrify(group).map((e) =>
        evt = @expandEvent(e)

        {
          evt: evt
          canDo: @hasRequirements(evt)
          slots: e.slots ? 1
        }
      )

      eventSlots.remove((def) -> not def.canDo)
      break unless eventSlots.isEmpty()

    if eventSlots?
      randEvt = @randEntry(eventSlots)
      return randEvt.evt if randEvt?

    null

  randEntry: (slotDefs, ctx={}) ->
    totalSlots = slotDefs.sum((e) -> e.slots ? 1)
    targetChance = (Math.random() * totalSlots)

    for entry in slotDefs
      targetChance -= entry.slots ? 1
      return entry if targetChance <= 0 or totalSlots == 0

    null

  doEffects: (entry) ->
    for key, val of entry
      @effs[key](val) if @effs[key]?
        
    return

  addText: (txt, entities=[]) ->
    if txt?
      text = TextHelper.parse(txt)
      text = TextHelper.replaceName(text, entities.map((ent) -> ent.name))
      $('#gameText').append("<p>#{text}</p>")

  doEvent: (eventIn, entity) ->
    event = Proto.getEvent(eventIn)
    console.log("do event [#{event.id}]") if event.id?

    if not entity?
      @addText(event.text) # only if party effect

    if event.image?
      $('#gameImage').css('background-image', "url(#{event.image}").fadeIn()
    else
      $('#gameImage').hide()

    @doEffects(event)
    @doEntityEffects(event.entityEffects)

    # actions
    for actionId in Core.arrify(event.actions)
      action = Proto.getEvent(actionId)

      if @hasRequirements(action)
        $('#gameText').append("
          <p class='action'>
            <a onClick=\"doAction('#{@actions.length}'); return false;\" href=''>
              #{action.actionText}
            </a>
          </p>")

        @actions.push(action)

    # follow-up events
    nextEventRef = @randEvent(event.events)
    @doEvent(nextEventRef) if nextEventRef?

  # do person oriented effects
  doEntityEffects: (effects, testOnly=false) =>
    return true if not effects?

    consumedEntities = []

    for eff in Core.arrify(effects)
      optional = eff.optional ? false
      continue if optional and testOnly

      evt = @expandEvent(eff)
      allEntities = @entities

      entities = allEntities.filter((ent) =>
        return false if ent in consumedEntities
        @hasRequirements(evt, ent)
      )
          
      count = evt.count ? 1
      failed = false
      
      if count is 'all'
        if entities.length < allEntities.length
          if optional then continue else return false

      else if count is 'any'
        # just keep entities

      else
        [minCount, maxCount] = Core.parseRange(count)
        return false if entities.length < minCount

        entities = entities.sample(maxCount)

      if entities.isEmpty()
        if optional then continue else return false

      unless testOnly
        continue if evt.chance? and Math.random()>evt.chance

        # add effect text for all entities at once
        @addText(evt.text, entities)
        
        # do event individually for each captured person
        for ent in entities.randomize()
          @doEvent(evt, ent)

          if eff.consume
            consumedPersons.push(ch)

    true

  setupExtensions: ->
    for evt in config.events
      if evt.extends?
        [id, slots] = evt.extends.split(':')

        parentEvt = Proto.getEvent(id)
        parentEvt.events ?= []
        parentEvt.events.push({ref:id, slots:parseInt(slots) ? 1})
 
# ---------------------------------------------

if window?
  window.doAction = (actionIdx) ->
    window.story.doAction(actionIdx)
    false

  window.startGame = ->
    window.story.startGame()

  window.editGame = ->
    window.story.editGame()

  window.help = ->
    window.story.showHelp()

  window.onload = ->
    window.story = new Story