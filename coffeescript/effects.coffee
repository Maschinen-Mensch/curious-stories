class Entity
  constructor: ->
    @attributes = {}

class Effects
  constructor: (story) ->
    @story = story

  setPartyFlags: (flags, entity) ->
    Core.setFlags(flags, @story.partyFlags)

  setFlags: (flags, entity) ->
    flagSet = if entity? then entity.partyFlags else @story.partyFlags
    Core.setFlags(flags, flagSet)

  setVar: (atts, entity) ->
    Object.merge(entity.attributes, Parser.parseAtts(atts))

  addEntity: (atts) ->
    newEntity = @story.addEntity()
    Object.merge(newEntity.attributes, Parser.parseAtts(atts))

  image: (img) ->
    $('#gameImage').css('background-image', "url(#{img}").fadeIn()

class Requirements
  constructor: (story) ->
    @story = story

  reqPartyFlags: (flags) ->
    Core.checkFlags(flags, @story.partyFlags)

  reqVar: (atts, entity) ->
    attrSet = Parser.parseAtts(atts)

    for key, val of attrSet
      if entity.attributes[key] isnt val
        return false

    true

  reqFlags: (flags, entity) ->
    flagSet = if entity? then entity.partyFlags else @story.partyFlags
    Core.checkFlags(flags, flagSet)

# ------------------export---------------------------

root = exports ? window
root.Requirements = Requirements
root.Effects = Effects
root.Entity = Entity
