CodeMirror.defineSimpleMode("curiousscript", {

  start: [
    {regex: /\w+/, token: "def", sol: true}, // event name
    {regex: /\s+:.*/, token: "tag", sol: true}, // command
    {regex: /\s+\w.+$/, token: "string", sol:true}, // text

    {regex: /([-\?])(.*>.*)/, token: ["keyword", "variable-3"]}, // inline action/event
    {regex: /([-\?])(.+)/, token: ["keyword", "string"]}, // reference action/event

    {regex: /#.*/, token: "comment"},


    // ---- UNUSED ----

    // You can match multiple tokens at once. Note that the captured
    // groups must span the whole string in this case
    // {regex: /(function)(\s+)([a-z$][\w$]*)/, token: ["keyword", null, "variable-2"]},

    // {regex: />|-|\?/, token: "keyword"},

    // {regex: /\s+:(?:\w.+)$/, token: ["keyword", "string"], sol:true}, // command

    // Rules are matched in the order in which they appear, so there is
    // no ambiguity between this one and the one above
    // {regex: /(?:function|var|return|if|for|while|else|do|this)\b/, token: "keyword"},

    // {regex: /true|false|null|undefined/, token: "atom"},

    // {regex: /0x[a-f\d]+|[-+]?(?:\.\d+|\d+\.?\d*)(?:e[-+]?\d+)?/i, token: "number"},


    // {regex: /\/(?:[^\\]|\\.)*?\//, token: "variable-3"},

    // A next property will cause the mode to move to a different state
    // {regex: /\/\*/, token: "comment", next: "comment"},

    // indent and dedent properties guide autoindentation
    // {regex: /[\{\[\(]/, indent: true},
    // {regex: /[\}\]\)]/, dedent: true},

    // {regex: /[a-z][\w]*/, token: "variable"},

    // You can embed other modes with the mode property. This rule
    // causes all code between << and >> to be highlighted with the XML
    // mode.
    // {regex: /<</, token: "meta", mode: {spec: "xml", end: />>/}}
  ],

  // The multi-line comment state.
  // comment: [
  //   {regex: /.*?\*\//, token: "comment", next: "start"},
  //   {regex: /.*/, token: "comment"}
  // ],

  // The meta property contains global information about the mode. It
  // can contain properties like lineComment, which are supported by
  // all modes, and also directives like dontIndentStates, which are
  // specific to simple modes.
  meta: {
    dontIndentStates: ["comment"],
    lineComment: "#"
  }
});
