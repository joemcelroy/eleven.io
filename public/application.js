(function() {
  String.prototype.score = function(abbreviation,offset) {
        
  if(abbreviation.length >=7) {
        return (this.indexOf(abbreviation) != -1)?1:0;
  }     
  offset = offset || 0 // TODO: I think this is unused... remove
 
  if(abbreviation.length == 0) return 0.9
  if(abbreviation.length > this.length) return 0.0

  for (var i = abbreviation.length; i > 0; i--) {
    var sub_abbreviation = abbreviation.substring(0,i)
    var index = this.indexOf(sub_abbreviation)


    if(index < 0) continue;
    if(index + abbreviation.length > this.length + offset) continue;

    var next_string       = this.substring(index+sub_abbreviation.length)
    var next_abbreviation = null

    if(i >= abbreviation.length)
      next_abbreviation = ''
    else
      next_abbreviation = abbreviation.substring(i)
 
    var remaining_score   = next_string.score(next_abbreviation,offset+index)
 
    if (remaining_score > 0) {
      var score = this.length-next_string.length;

      if(index != 0) {
        var j = 0;

        var c = this.charCodeAt(index-1)
        if(c==32 || c == 9) {
          for(var j=(index-2); j >= 0; j--) {
            c = this.charCodeAt(j)
            score -= ((c == 32 || c == 9) ? 1 : 0.15)
          }
        } else {
          score -= index
        }
      }
   
      score += remaining_score * next_string.length
      score /= this.length;
      return score
    }
  }
  

  return 0.0
};

  var __hasProp = {}.hasOwnProperty,
    __extends = function(child, parent) { for (var key in parent) { if (__hasProp.call(parent, key)) child[key] = parent[key]; } function ctor() { this.constructor = child; } ctor.prototype = parent.prototype; child.prototype = new ctor(); child.__super__ = parent.prototype; return child; },
    __bind = function(fn, me){ return function(){ return fn.apply(me, arguments); }; };

  App.Eleven = (function(_super) {

    __extends(Eleven, _super);

    function Eleven() {
      return Eleven.__super__.constructor.apply(this, arguments);
    }

    Eleven.prototype.urlRoot = "/eleven-api";

    Eleven.prototype._findFirstUndefined = function(players) {
      var i, player, _i, _len;
      for (i = _i = 0, _len = players.length; _i < _len; i = ++_i) {
        player = players[i];
        if (typeof player === "undefined") {
          return i;
        }
      }
      return this._size(players);
    };

    Eleven.prototype._size = function(players) {
      var definedPlayers;
      definedPlayers = _.filter(players, function(player) {
        return typeof player !== "undefined";
      });
      return _.size(definedPlayers);
    };

    Eleven.prototype.playersSize = function() {
      return this._size(this.get("players"));
    };

    Eleven.prototype.updatePlayer = function(id) {
      var nextSpot, players, pos;
      players = this.get("players");
      if (_.indexOf(players, id) !== -1) {
        pos = _.indexOf(players, id);
        players[pos] = void 0;
      } else if (this._size(players) <= 11) {
        nextSpot = this._findFirstUndefined(players);
        players[nextSpot] = id;
      }
      this.set("players", players);
      return this.trigger("change:players");
    };

    Eleven.prototype.movePlayer = function(id, newPos) {
      var movedPlayer, oldPos, players, prevPosPlayer;
      players = this.get("players");
      oldPos = _.indexOf(players, id);
      if ((players[newPos] != null) && players[newPos] !== 0) {
        movedPlayer = players[oldPos];
        prevPosPlayer = players[newPos];
        players[newPos] = movedPlayer;
        players[oldPos] = prevPosPlayer;
      } else {
        players[oldPos] = void 0;
        players[newPos] = id;
      }
      this.set("players", players);
      return this.trigger("change:players");
    };

    return Eleven;

  })(Backbone.Model);

  App.Player = (function(_super) {

    __extends(Player, _super);

    function Player() {
      return Player.__super__.constructor.apply(this, arguments);
    }

    Player.prototype.getName = function() {
      var nameSplit;
      nameSplit = this.get("name").split(" ");
      return _.last(nameSplit);
    };

    return Player;

  })(Backbone.Model);

  App.Team = (function(_super) {

    __extends(Team, _super);

    function Team() {
      return Team.__super__.constructor.apply(this, arguments);
    }

    return Team;

  })(Backbone.Model);

  App.PlayersCollection = (function(_super) {

    __extends(PlayersCollection, _super);

    function PlayersCollection() {
      return PlayersCollection.__super__.constructor.apply(this, arguments);
    }

    PlayersCollection.prototype.model = App.Player;

    PlayersCollection.prototype.search = function(term, exclusions) {
      var c, name, score, scores, _i, _len, _ref;
      if (term == null) {
        term = "";
      }
      if (exclusions == null) {
        exclusions = [];
      }
      term = term.toLowerCase();
      scores = [];
      _ref = this.models;
      for (_i = 0, _len = _ref.length; _i < _len; _i++) {
        c = _ref[_i];
        if (!($.inArray(c.id, exclusions) > -1)) {
          name = c.get("name").toLowerCase();
          score = name.score(term);
          if (score > 0.1) {
            scores.push({
              score: score,
              item: c
            });
          }
        }
      }
      scores = scores.sort(function(a, b) {
        return b.score - a.score;
      });
      return scores;
    };

    return PlayersCollection;

  })(Backbone.Collection);

  App.TeamsCollection = (function(_super) {

    __extends(TeamsCollection, _super);

    function TeamsCollection() {
      return TeamsCollection.__super__.constructor.apply(this, arguments);
    }

    TeamsCollection.prototype.model = App.Team;

    return TeamsCollection;

  })(Backbone.Collection);

  App.FormationSelectView = (function(_super) {

    __extends(FormationSelectView, _super);

    FormationSelectView.prototype.el = "select";

    FormationSelectView.prototype.events = {
      "change": "changeEvent"
    };

    function FormationSelectView(settings) {
      this.render = __bind(this.render, this);

      this.changeEvent = __bind(this.changeEvent, this);
      _.extend(this, settings);
      this.bind();
      FormationSelectView.__super__.constructor.apply(this, arguments);
    }

    FormationSelectView.prototype.bind = function() {
      return this.elevenModel = app.elevenModel;
    };

    FormationSelectView.prototype.changeEvent = function() {
      var formation;
      formation = this.$el.val();
      return this.elevenModel.set("formation", formation);
    };

    FormationSelectView.prototype.getSearchValue = function() {
      return this.$el.val();
    };

    FormationSelectView.prototype.render = function() {};

    return FormationSelectView;

  })(Backbone.View);

  App.PitchView = (function(_super) {

    __extends(PitchView, _super);

    PitchView.prototype.template = "<li id=\"p<%= playerNumber %>\" <% if (typeof(player) != \"undefined\") { %> data-id=\"<%= player.id %>\" class=\"active\" <% } %> >\n  <span></span>\n  <canvas id=\"myCanvas\" width=\"22\" height=\"22\"></canvas>\n  <% if (typeof(player) != \"undefined\") { %>\n    <strong><%= player.getName() %></strong>\n  <% } else { %>\n    <strong></strong>\n  <% } %>  \n</li>";

    PitchView.prototype.el = "article ul";

    PitchView.prototype.events = {
      "click li.active": "removePlayer"
    };

    function PitchView(settings) {
      this.render = __bind(this.render, this);

      this.changeFormation = __bind(this.changeFormation, this);
      _.extend(this, settings);
      this.bind();
      PitchView.__super__.constructor.apply(this, arguments);
    }

    PitchView.prototype.bind = function() {
      this.playersCollection = app.playersCollection;
      this.elevenModel = app.elevenModel;
      this.elevenModel.on("change:players", this.render, this);
      this.elevenModel.on("change:formation", this.changeFormation, this);
      return this.bindViews();
    };

    PitchView.prototype.bindViews = function() {
      this.SearchInputView = new App.SearchInputView();
      this.FormationSelectView = new App.FormationSelectView();
      return this.shareView = new App.ShareActionView();
    };

    PitchView.prototype.removePlayer = function(e) {
      var playerId;
      playerId = $(e.target).closest("li").data("id");
      return this.elevenModel.updatePlayer(playerId);
    };

    PitchView.prototype.movePlayer = function(playerId, newPos) {
      return this.elevenModel.movePlayer(playerId, newPos);
    };

    PitchView.prototype.makeDraggable = function() {
      var _this = this;
      this.$("li.active").draggable({
        revert: true,
        start: function() {
          return $("body").addClass("inDrag");
        },
        stop: function() {
          return $("body").removeClass("inDrag");
        }
      });
      return this.$("li").droppable({
        hoverClass: "dragover",
        drop: function(e, payload) {
          var newPos, playerId, target;
          target = $(e.target);
          newPos = target.index();
          playerId = payload.draggable.data("id");
          _this.movePlayer(playerId, newPos);
          return $("body").removeClass("inDrag");
        }
      });
    };

    PitchView.prototype.changeFormation = function() {
      return this.$el.attr("class", this.elevenModel.get("formation"));
    };

    PitchView.prototype.renderBlankState = function(players) {
      var size;
      $("body .blank").remove();
      size = this.elevenModel._size(players);
      if (size < 1) {
        return $("body").append("\n  <div class=\"blank\">\n    <h1>Search and share your starting eleven for 2012/13.</h1>\n    <h2>From Premiership to Bundesliga, add, delete, drag & swap players. Who would you sign this January transfer window?</h2>\n    <a href=\"#\" class=\"close\">x</a>\n  </div>\n");
      }
    };

    PitchView.prototype.render = function() {
      var className, html, i, player, playerId, players, _i;
      html = "";
      players = this.elevenModel.get("players");
      this.renderBlankState(players);
      for (i = _i = 0; _i <= 10; i = ++_i) {
        playerId = players[i];
        player = this.playersCollection.get(playerId);
        if (typeof player !== "undefined") {
          className = "assigned";
        }
        html += _.template(this.template, {
          player: this.playersCollection.get(playerId),
          className: className,
          playerNumber: i + 1
        });
      }
      this.$el.html(html);
      this.$el.attr("class", this.elevenModel.get("formation"));
      this.makeDraggable();
      return this;
    };

    return PitchView;

  })(Backbone.View);

  App.SearchAutocompleteView = (function(_super) {

    __extends(SearchAutocompleteView, _super);

    SearchAutocompleteView.prototype.className = "autocomplete";

    SearchAutocompleteView.prototype.tagName = "ul";

    SearchAutocompleteView.prototype.template = "<li data-id=\"<%= player.id %>\" class=\"<%= className %>\"><a href=\"#\"><strong> <%= player.get(\"name\") %> </strong> <em> <%= team.get(\"name\") %> </em> </a> </li>";

    SearchAutocompleteView.prototype.noResultsTemplate = "<li class=\"noResults\">No players found. Are you sure you're a football fan?</li>";

    SearchAutocompleteView.prototype.events = {
      "click": "clickEvent"
    };

    function SearchAutocompleteView(settings) {
      this.render = __bind(this.render, this);

      this.keyUpEvent = __bind(this.keyUpEvent, this);

      this.clickEvent = __bind(this.clickEvent, this);
      _.extend(this, settings);
      this.bind();
      SearchAutocompleteView.__super__.constructor.apply(this, arguments);
    }

    SearchAutocompleteView.prototype.bind = function() {
      this.on("keyup", this.keyUpEvent);
      this.playersCollection = app.playersCollection;
      this.teamCollection = app.teamCollection;
      return this.elevenModel = app.elevenModel;
    };

    SearchAutocompleteView.prototype.clickEvent = function(e) {
      var li, playerId;
      li = $(e.target).closest("li");
      playerId = li.data("id");
      this.updatePlayer(playerId);
      return this.hide();
    };

    SearchAutocompleteView.prototype.updatePlayer = function(id) {
      this.elevenModel.updatePlayer(id);
      this.parent.clear();
      return this.render();
    };

    SearchAutocompleteView.prototype.keyUpEvent = function(e) {
      var events, key, nextElem, prevElem, selected;
      events = {
        13: "enter",
        40: "down",
        38: "up",
        27: "esc"
      };
      key = events[e.keyCode];
      selected = this.$("li.selected");
      if (key === "enter" && selected.length === 1) {
        this.updatePlayer(selected.data("id"));
        return this.hide();
      } else if (key === "down" && selected.length === 1) {
        nextElem = selected.next();
        if (nextElem.length === 1) {
          selected.removeClass("selected");
          return nextElem.addClass("selected");
        }
      } else if (key === "up" && selected.length === 1) {
        prevElem = selected.prev();
        if (prevElem.length === 1) {
          selected.removeClass("selected");
          return prevElem.addClass("selected");
        }
      } else if (key === "esc") {
        return this.hide();
      } else {
        this.value = this.parent.getSearchValue();
        return this.render();
      }
    };

    SearchAutocompleteView.prototype.hide = function() {
      return this.$el.html("");
    };

    SearchAutocompleteView.prototype.render = function() {
      var html, i, player, players, playersSelected, team, value, _i, _len;
      value = this.value;
      if (value === "") {
        return this.$el.html("");
      }
      players = this.playersCollection.search(value);
      playersSelected = this.elevenModel.get("players");
      players = _.filter(players, function(player) {
        return _.indexOf(playersSelected, player.item.id) === -1;
      });
      html = "";
      if (players.length > 0) {
        for (i = _i = 0, _len = players.length; _i < _len; i = ++_i) {
          player = players[i];
          team = this.teamCollection.get(player.item.get("team"));
          html += _.template(this.template, {
            player: player.item,
            team: team,
            className: (i === 0 ? "selected" : void 0)
          });
          if (i === 5) {
            break;
          }
        }
      } else {
        html = this.noResultsTemplate;
      }
      this.$el.html(html);
      return this;
    };

    return SearchAutocompleteView;

  })(Backbone.View);

  App.SearchInputView = (function(_super) {

    __extends(SearchInputView, _super);

    SearchInputView.prototype.el = "header form input";

    SearchInputView.prototype.events = {
      "keyup": "keyUpEvent"
    };

    function SearchInputView(settings) {
      this.hideSearch = __bind(this.hideSearch, this);
      _.extend(this, settings);
      this.bind();
      SearchInputView.__super__.constructor.apply(this, arguments);
    }

    SearchInputView.prototype.keyUpEvent = function(e) {
      this.autocompleteView.trigger("keyup", e);
      return e.preventDefault();
    };

    SearchInputView.prototype.bind = function() {
      this.elevenModel = app.elevenModel;
      this.elevenModel.on("change change:players", this.hideSearch);
      this.autocompleteView = new App.SearchAutocompleteView({
        parent: this
      });
      this.autocompleteView.$el.appendTo("body");
      return $("form").submit(function(e) {
        return e.preventDefault();
      });
    };

    SearchInputView.prototype.hideSearch = function() {
      if (this.elevenModel.playersSize() === 11) {
        return this.$el.addClass("hide");
      } else {
        return this.$el.removeClass("hide");
      }
    };

    SearchInputView.prototype.getSearchValue = function() {
      return this.$el.val();
    };

    SearchInputView.prototype.clear = function() {
      this.$el.val("");
      return this.$el.focus();
    };

    return SearchInputView;

  })(Backbone.View);

  App.ShareActionView = (function(_super) {

    __extends(ShareActionView, _super);

    ShareActionView.prototype.shareOverlayTemplate = "<div class=\"pop share\" style=\"display: block;\">\n<span class=\"close\"></span>\n<h2>Share your team</h2>\n<input type=\"text\" value=\"<%= shareUrl %>\" autofocus>\n</div>";

    ShareActionView.prototype.el = "header form a.share";

    ShareActionView.prototype.events = {
      "click": "clickEvent"
    };

    function ShareActionView(settings) {
      this.clickEvent = __bind(this.clickEvent, this);

      this.showButton = __bind(this.showButton, this);

      this.hideShareOverlay = __bind(this.hideShareOverlay, this);
      _.extend(this, settings);
      this.bind();
      ShareActionView.__super__.constructor.apply(this, arguments);
    }

    ShareActionView.prototype.bind = function() {
      this.elevenModel = app.elevenModel;
      this.elevenModel.on("change change:players", this.showButton);
      $("body").on("click", ".pop.share .close", this.hideShareOverlay);
      if (location.href.indexOf("#share") !== -1) {
        return this.showShareOverlay();
      }
    };

    ShareActionView.prototype.showShareOverlay = function() {
      var overlay;
      overlay = _.template(this.shareOverlayTemplate, {
        shareUrl: location.href.replace("#share", "")
      });
      return $("body").append(overlay);
    };

    ShareActionView.prototype.hideShareOverlay = function() {
      $("div.pop.share").remove();
      return location.href = location.href.replace("#share", "#");
    };

    ShareActionView.prototype.showButton = function() {
      if (this.elevenModel.playersSize() === 11) {
        this.$el.addClass("show");
        return this.$el.focus();
      } else {
        return this.$el.removeClass("show");
      }
    };

    ShareActionView.prototype.clickEvent = function(e) {
      e.preventDefault();
      return this.elevenModel.save(null, {
        success: function(model, response) {
          return location.href = "/" + response.item._id + "#share";
        }
      });
    };

    return ShareActionView;

  })(Backbone.View);

}).call(this);
