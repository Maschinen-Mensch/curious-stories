class Story
  constructor: ->
    @reqs = new Requirements(this)
    @effs = new Effects(this)

    $('#game').hide()

  startGame: ->
    @partyFlags = {}
    @entities = []
    @eventCounts = {}

    try
      code = window.firepad.getText().split('\n')
      [config.events, @errors] = Parser.parse(code)

      if @errors.length > 0
        firstError = @errors[0]
        $('#errors').html("#{@errors.length} ERRORS - #{firstError.text}:#{firstError.lineIdx}").show()
        return false
      else
        $('#errors').hide()

      $('#firepad-container').hide()
      $('#help').hide()
      $('#gameText').empty()
      $('#game').show()

      @showEvent(config.events[0])

    catch e
      alert(e.message)
      return false

  editGame: ->
    $('#game').hide()    
    $('#help').show()    
    $('#firepad-container').show()

  addEntity: ->
    newEntity = new Entity()
    @entities.push(newEntity)
    newEntity

  showEvent: (eventId) ->
    $('#gameText .action').remove()
    $('#gameImage').hide()
    $('#gameText p').addClass('old')

    @actions = []

    if Object.isString(eventId) # id
      @eventCounts[eventId] ?= 0
      @eventCounts[eventId] += 1

    # resolve event id
    @doEvent(Proto.getEvent(eventId))

    for action, actionIdx in @actions
      $('#gameText').append("
        <p class='action'>
          <a onClick=\"doAction('#{actionIdx}'); return false;\" href=''>
            #{action.actionText}
          </a>
        </p>")

    if @actions.length == 0 # game over
      $('#gameText').append("<p><a class=start href='' onClick='startGame(); return false;'>New Game</a></p>")

  doAction: (actionIdx) ->
    action = @actions[actionIdx]
    @showEvent(action)

  hasRequirements: (event, entity) ->
    Core.assert(Object.isObject(event))

    for cmd in event.commands
      if cmd.op.startsWith('req')
        Core.assert(@reqs[cmd.op]?, "Unknown requirement #{cmd.op}")

        if not @reqs[cmd.op](cmd.arg, entity)
          console.warn("failed requirement #{cmd.op} for event #{event.id ? 'inline'}")
          return false

    if not @doEntityEffects(event.effects, true)
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

  doCommands: (entry) ->
    for cmd in entry.commands
      @effs[cmd.op](cmd.arg) if @effs[cmd.op]?
        
    return

  addText: (txt, entity) ->
    klass = if entity? then 'special' else ''

    if txt?
      txt = TextHelper.parse(txt)
      # text = TextHelper.replaceName(text, entities.map((ent) -> ent.name))

      if entity?
        txt = TextHelper.replaceAtts(txt, entity.attributes)

      $('#gameText').append("<p class=#{klass}>#{txt}</p>")

  doEvent: (event, entity) ->
    Core.assert(Object.isObject(event))
    console.log("do event [#{event.id}]") if event.id?

    @addText(event.text, entity)

    @doCommands(event)
    @doEntityEffects(event.effects)

    # actions
    for actionId in Core.arrify(event.actions)
      action = Proto.getEvent(actionId)

      if @hasRequirements(action)
        @actions.push(action)

    # follow-up events
    nextEventRef = @randEvent(event.events)
    @doEvent(nextEventRef) if nextEventRef?

  # do person oriented effects
  doEntityEffects: (effects, testOnly=false) =>
    return true if not effects?

    consumedEntities = []

    for eff in Core.arrify(effects)
      optional = eff.optional ? true
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
        if entities.length < minCount
          if optional then continue else return false

        entities = entities.sample(maxCount)

      if entities.isEmpty()
        if optional then continue else return false

      unless testOnly
        continue if evt.chance? and Math.random()>evt.chance

        # @addText(evt.text, entities)
        
        # do event individually for each captured person
        for ent in entities.randomize()
          @doEvent(evt, ent)

          if eff.consume
            consumedPersons.push(ch)

    true

 
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