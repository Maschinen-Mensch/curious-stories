class Entity
  constructor: ->
    @attributes = {}

class Effects
  constructor: (story) ->
    @story = story

  setPartyFlags: (flags, entity) ->
    Core.setFlags(flags, @story.partyFlags)

  setFlags: (flats, entity) ->
    Core.setFlags(flags, entity.flags)

  addEntity: (count) ->
    for i in [0...count]
      @story.addEntity()

class Requirements
  constructor: (story) ->
    @story = story

  reqPartyFlags: (flags) ->
    Core.checkFlags(flags, @story.partyFlags)

  reqFlags: (flags, entity) ->
    Core.checkFlags(flags, entity.flags)

# ------------------export---------------------------

root = exports ? window
root.Requirements = Requirements
root.Effects = Effects
root.Entity = Entity