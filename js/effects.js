// Generated by CoffeeScript 1.6.2
(function() {
  var Effects, Entity, Requirements, root;

  Entity = (function() {
    function Entity() {
      this.attributes = {};
    }

    return Entity;

  })();

  Effects = (function() {
    function Effects(story) {
      this.story = story;
    }

    Effects.prototype.setPartyFlags = function(flags, entity) {
      return Core.setFlags(flags, this.story.partyFlags);
    };

    Effects.prototype.setFlags = function(flats, entity) {
      return Core.setFlags(flags, entity.flags);
    };

    Effects.prototype.addEntity = function(count) {
      var i, _i, _results;

      _results = [];
      for (i = _i = 0; 0 <= count ? _i < count : _i > count; i = 0 <= count ? ++_i : --_i) {
        _results.push(this.story.addEntity());
      }
      return _results;
    };

    return Effects;

  })();

  Requirements = (function() {
    function Requirements(story) {
      this.story = story;
    }

    Requirements.prototype.reqPartyFlags = function(flags) {
      return Core.checkFlags(flags, this.story.partyFlags);
    };

    Requirements.prototype.reqFlags = function(flags, entity) {
      return Core.checkFlags(flags, entity.flags);
    };

    return Requirements;

  })();

  root = typeof exports !== "undefined" && exports !== null ? exports : window;

  root.Requirements = Requirements;

  root.Effects = Effects;

  root.Entity = Entity;

}).call(this);
