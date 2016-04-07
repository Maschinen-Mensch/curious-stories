debug = {
}

config = {};

config.entities = [
  {
    name: "[Jack|Sara|Bob|Laura]",
    type: 'character',
    $sanity: '5..10'
  }
]

config.events = [
  {
    id: 'evt-start',
    addEntity: 3,
    events: 'evt-mansion'
  },
  {
    id: 'evt-mansion',
    text: "I'm standing in the living room.",
    entityEffects: [
      {
        count: 1,
        text: "$name is looking a bit nervous.",
        $reqSanity: '..5'
      },
      {
        count: 1,
        chat: "We should keep moving!"
      }
    ],
    actions: [
      'evt-basement',
      'evt-attic'
    ]
  },
  {
    id: 'evt-basement',
    actionText: "Investigate basement",
    text: "You walk left and are struck by lightning."
  },
  {
    id: 'evt-attic',
    actionText: "Investigate attic",
    text: "You walk right.",
    events: 'evt-mansion-random'
  },
  {
    id: 'evt-mansion-random',
    events: [
      {slots: 01, ref:'evt-mansion-castle'},
      {slots: 01, ref:'evt-mansion-pit'},
    ]
  },
  {
    id: 'evt-mansion-castle',
    text: "We arrived at a giant castle.",
    actions: [
      {
        actionText: "Knock on door.",
        text: "You are attacked and killed."
      },
      {
        actionText: "Ignore castle and continue on path.",
        events: 'evt-mansion-random'
      }
    ]
  },
  {
    id: 'evt-mansion-pit',
    text: "We arrived at a pit.",
    actions: [
      {
        actionText: "Jump over it.",
        text: "You fall into the pit and die."
      },
      {
        actionText: "Use rope.",
        text: "You use the rope to reach the other side.",
        reqPartyFlags: '+rope',
        setPartyFlags: '-rope',
        events: 'evt-mansion-random'
      },
      {
        actionText: "Turn around.",
        events: 'evt-mansion-random'
      }
    ]
  },
  {
    id: 'evt-mansion-rope',
    extends: 'evt-mansion-random:10',
    text: "You find a rope.", 
    reqPartyFlags: '-rope',
    setPartyFlags: '+rope',
    events: 'evt-mansion-random'
  },
]