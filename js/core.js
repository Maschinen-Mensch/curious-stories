// Generated by CoffeeScript 1.12.7
(function() {
  var Core, Proto, TextHelper, root;

  Proto = (function() {
    function Proto() {}

    Proto.getEvent = function(id) {
      var evt;
      if (Object.isObject(id)) {
        return id;
      }
      evt = config.events.filter(function(e) {
        return e.id === id;
      }).sample();
      Core.assert(evt != null, "Event with ID " + id + " not found");
      return evt;
    };

    return Proto;

  })();

  TextHelper = (function() {
    function TextHelper() {}

    TextHelper.replaceAtts = function(text, atts) {
      if (atts == null) {
        atts = {};
      }
      return text.replace(/\$\w+/g, function(match) {
        return atts[match.slice(1)];
      });
    };

    TextHelper.replaceName = function(text, names) {
      var i, j, len, name, nameTxt;
      if (names == null) {
        names = [];
      }
      names = Core.arrify(names);
      nameTxt = '';
      for (i = j = 0, len = names.length; j < len; i = ++j) {
        name = names[i];
        if (names.length > 1 && i === names.length - 1) {
          nameTxt += ' and ';
        }
        nameTxt += name;
        if (i < names.length - 2) {
          nameTxt += ', ';
        }
      }
      text = text.replace('$name', nameTxt);
      if (names.length > 1) {
        text = text.replace('$is', "are");
        text = text.replace('$i', "we");
        text = text.replace('$I', "We");
      } else {
        text = text.replace('$is', "is");
        text = text.replace('$i', "I");
        text = text.replace('$I', "I");
      }
      return text;
    };

    TextHelper.parse = function(txt, gender) {
      var altTexts, j, len, match, matches, replacement, shortMatch;
      if (gender == null) {
        gender = 'male';
      }
      if (gender === 'female') {
        txt = txt.replace('$He', "She");
        txt = txt.replace('$His', "Her");
        txt = txt.replace('$Him', "Her");
        txt = txt.replace('$he', "she");
        txt = txt.replace('$his', "her");
        txt = txt.replace('$him', "her");
      } else {
        txt = txt.replace('$He', "He");
        txt = txt.replace('$His', "His");
        txt = txt.replace('$Him', "Him");
        txt = txt.replace('$he', "he");
        txt = txt.replace('$his', "his");
        txt = txt.replace('$him', "him");
      }
      matches = txt.match(/\[.*?\]/g);
      if (matches != null) {
        for (j = 0, len = matches.length; j < len; j++) {
          match = matches[j];
          shortMatch = match.slice(1, -1);
          altTexts = shortMatch.split('|');
          replacement = altTexts.length > 1 ? altTexts.sample() : Math.random() < 0.5 ? altTexts[0] : '';
          txt = txt.replace(match, replacement);
        }
      }
      return txt;
    };

    return TextHelper;

  })();

  Core = (function() {
    function Core() {}

    Core.arrify = function(ids, expandString) {
      if (expandString == null) {
        expandString = true;
      }
      if (ids == null) {
        return [];
      }
      if (expandString && Object.isString(ids)) {
        return ids.split(' ');
      }
      if (Object.isArray(ids)) {
        return ids;
      } else {
        return [ids];
      }
    };

    Core.strFlags = function(flags) {
      var entries, id, val;
      entries = [];
      for (id in flags) {
        val = flags[id];
        if (val) {
          entries.push(id);
        }
      }
      return entries.join(' ');
    };

    Core.setFlags = function(flagSet, actualFlags) {
      var flags;
      if (actualFlags == null) {
        actualFlags = {};
      }
      flags = this.parseFlags(flagSet).sample();
      return Object.merge(actualFlags, flags);
    };

    Core.parseFlags = function(flagSet, prefix) {
      var andSet, flag, flagGroup, j, k, len, len1, orSet, ref, ref1;
      if (prefix == null) {
        prefix = '';
      }
      if (Object.isString(flagSet)) {
        orSet = [];
        ref = flagSet.split('|');
        for (j = 0, len = ref.length; j < len; j++) {
          flagGroup = ref[j];
          andSet = {};
          ref1 = flagGroup.split(' ');
          for (k = 0, len1 = ref1.length; k < len1; k++) {
            flag = ref1[k];
            flag = flag.trim();
            if (flag.length > 0) {
              Core.assert(flag[0] === '+' || flag[0] === '-', "flag " + flag + " needs to start with + or -");
              andSet[prefix + flag.slice(1)] = flag[0] === '+';
            }
          }
          orSet.push(andSet);
        }
        return orSet;
      } else {
        return Core.arrify(flagSet);
      }
    };

    Core.checkFlags = function(flagSet, actualFlags) {
      if (Object.isBoolean(flagSet)) {
        return flagSet;
      }
      flagSet = this.parseFlags(flagSet);
      return Core.arrify(flagSet).any(function(reqFlags) {
        return Object.all(reqFlags, function(id, val) {
          var entry, ref;
          entry = (ref = actualFlags[id]) != null ? ref : false;
          return entry === val;
        });
      });
    };

    Core.parseRange = function(range, attributes) {
      var a, b, parse, ref, ref1, ref2, ref3, ref4, ref5, ref6, temp, xMax, xMin;
      if (attributes == null) {
        attributes = {};
      }
      parse = function(x) {
        var val;
        val = attributes[x];
        if (val != null) {
          return val;
        }
        val = parseInt(x);
        if (!isNaN(val)) {
          return val;
        } else {
          return null;
        }
      };
      if (Object.isString(range)) {
        ref = range.split('..'), a = ref[0], b = ref[1];
        if (b == null) {
          xMin = xMax = parse(a);
        } else if (b[0] === '.') {
          xMin = (ref1 = parse(a)) != null ? ref1 : -10000;
          if (b.length > 1) {
            xMax = (ref2 = parse(b.slice(1)) - 1) != null ? ref2 : 10000;
          } else {
            xMax = xMin;
          }
        } else {
          xMin = (ref3 = parse(a)) != null ? ref3 : -100000;
          xMax = (ref4 = parse(b)) != null ? ref4 : 100000;
        }
      } else if (Object.isArray(range)) {
        if (range.length === 2) {
          ref5 = [range[0], range[1]], xMin = ref5[0], xMax = ref5[1];
        } else if (range.length === 1) {
          ref6 = [range[0], range[0]], xMin = ref6[0], xMax = ref6[1];
        } else {
          Core.assert(false, "Invalid int range length (" + range.length + ")");
        }
        if (xMin > xMax) {
          temp = xMin;
          xMin = xMax;
          xMax = temp;
        }
      } else {
        xMin = range;
        xMax = range;
      }
      return [xMin, xMax];
    };

    Core.randRange = function(range) {
      var ref, xMax, xMin;
      ref = this.parseRange(range), xMin = ref[0], xMax = ref[1];
      return Number.random(xMin, xMax);
    };

    Core.match = function(range, x, attributes) {
      var ref, xMax, xMin;
      if (attributes == null) {
        attributes = {};
      }
      ref = this.parseRange(range, attributes), xMin = ref[0], xMax = ref[1];
      return (xMax >= x && x >= xMin);
    };

    Core.parseText = function(txt) {
      var match, regex;
      regex = /(\§\w+)/;
      while (true) {
        match = regex.exec(txt);
        if (match == null) {
          break;
        }
        txt = txt.replace(match[1], config.strings[match[1].from(1)].sample());
      }
      return txt;
    };

    Core.parseMentions = function(txt, entities) {
      var ent, i, j, mentions, name, secretMention;
      mentions = [];
      for (i = j = 0; j < 6; i = ++j) {
        if (txt.indexOf("$" + i) > -1) {
          ent = entities[i];
          secretMention = false;
          if (txt.indexOf("$" + i + "f") > -1) {
            name = ent != null ? ent.firstName : '';
            txt = txt.replace("$" + i + "f", name);
            secretMention = true;
          }
          if (txt.indexOf("$" + i + "l") > -1) {
            name = ent != null ? ent.lastName : '';
            txt = txt.replace("$" + i + "l", name);
            secretMention = true;
          }
          if (txt.indexOf("$" + i + "i") > -1) {
            name = ent != null ? ent.firstName[0] + ". " + ent.lastName[0] + "." : '';
            txt = txt.replace("$" + i + "i", name);
            secretMention = true;
          }
          if (!secretMention) {
            name = ent != null ? ent.fullName() : '';
            txt = txt.replace("$" + i, name);
            mentions.push(ent);
          }
        }
      }
      return [txt, mentions];
    };

    Core.clamp = function(val, min, max) {
      return Math.max(Math.min(val, max), min);
    };

    Core.assert = function(exp, message) {
      if (!exp) {
        console.error(message);
        console.trace();
        debugger;
      }
    };

    return Core;

  })();

  root = typeof exports !== "undefined" && exports !== null ? exports : window;

  root.Core = Core;

  root.Proto = Proto;

  root.TextHelper = TextHelper;

}).call(this);
