`String.prototype.score = function(abbreviation,offset) {
        
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
}`
class App.Eleven extends Backbone.Model
  urlRoot: "/eleven-api"
  
  _findFirstUndefined: (players) ->
    for player,i in players
      if typeof player is "undefined"
        return i
    
    @_size players
  
  _size: (players) ->
    definedPlayers = _.filter players, (player) ->
      typeof player isnt "undefined"
    
    _.size definedPlayers
  
  updatePlayer:(id) ->
    players = @get "players"
    
    if _.indexOf(players, id) isnt -1
      # remove player
      pos = _.indexOf(players, id)
      players[pos] = undefined
    
    else if @_size(players) <= 11
      nextSpot = @_findFirstUndefined players
      players[nextSpot] = id
      
    @set "players", players
    @trigger "change:players"
  
  movePlayer:(id, newPos) ->
    players = @get "players"
    oldPos = _.indexOf players, id
    
    if players[newPos]? and players[newPos] != 0
      
      movedPlayer = players[oldPos]
      prevPosPlayer = players[newPos]
      
      players[newPos] = movedPlayer
      players[oldPos] = prevPosPlayer
    
    else  
      players[oldPos] = undefined
      players[newPos] = id
    
    @set "players", players
    @trigger "change:players"
    
     
    
    
    
    
     
    
  
  
  
  
class App.Player extends Backbone.Model

  getName: ->
    nameSplit = @get("name").split(" ")
    _.last nameSplit
class App.Team extends Backbone.Model

class App.PlayersCollection extends Backbone.Collection
  model: App.Player
  
  search:(term="", exclusions=[])->
      term = term.toLowerCase()
      scores = []
      for c in @models
        unless $.inArray(c.id, exclusions) > -1
          name = c.get("name").toLowerCase()
          score = name.score(term)
          if score > 0.1 
            scores.push 
              score:score
              item:c

      scores = scores.sort (a, b)-> b.score - a.score    
      scores
class App.TeamsCollection extends Backbone.Collection
  model: App.Team
class App.FormationSelectView extends Backbone.View

  el:"header select"
  
  events:
    "change": "changeEvent"
  
  constructor: (settings) ->
    _.extend @, settings
    @bind()
    super
    
  bind: ->
    @elevenModel = app.elevenModel
    
  changeEvent: =>
    formation = @$el.val()
    @elevenModel.set "formation", formation
    
  getSearchValue: ->
    @$el.val()
    
  render: =>
    

class App.PitchView extends Backbone.View
  
  template: """
  <li id="p<%= playerNumber %>" <% if (typeof(player) != "undefined") { %> data-id="<%= player.id %>" class="active" <% } %> >
    <span></span>
    <canvas id="myCanvas" width="22" height="22"></canvas>
    <% if (typeof(player) != "undefined") { %>
      <strong><%= player.getName() %></strong>
    <% } else { %>
      <strong></strong>
    <% } %>  
  </li>"""
  
  el:"article ul"
  
  events:
    "click li.active": "removePlayer"
  
  constructor: (settings) ->
    _.extend @, settings
    @bind()
    super
    
  bind: ->
    @playersCollection = app.playersCollection
    @elevenModel = app.elevenModel
    @elevenModel.on "change:players", @render, @
    @elevenModel.on "change:formation", @changeFormation, @
    
    @bindViews()
    
  bindViews: ->
    @SearchInputView = new App.SearchInputView()
    @FormationSelectView = new App.FormationSelectView()
    @shareView = new App.ShareActionView()
    
  removePlayer: (e) ->
    playerId = $(e.target).closest("li").data("id")
    @elevenModel.updatePlayer playerId
    
  movePlayer: (playerId, newPos) ->
    @elevenModel.movePlayer playerId, newPos
    
  makeDraggable: ->
    
    @$("li.active").draggable {
      revert: true
    }
    @$("li").droppable {
        hoverClass: "dragover",
        drop: (e, payload) =>
          target = $(e.target)
          newPos = target.index()
          playerId = payload.draggable.data("id")
          @movePlayer playerId, newPos
    }
    
  changeFormation: =>
    @$el.attr("class", @elevenModel.get("formation") )
      
  renderBlankState: (players) ->
    $("body .blank").remove()
    
    
    size = @elevenModel._size(players)
    
    if size < 3
    
      $("body").append """
    
      <div class="blank step#{size+1}">
        <span>i</span>
        <span>i</span>
        <span>i</span>
        <span>i</span>
        <span>2. Delete, drag and swap</span>
        <span>3. Formations and share your team</span>
        <span>1. Start with your goalie</span>
      </div>
    
      """
    
  render: =>
        
    html = ""
        
    players = @elevenModel.get("players")
    
    @renderBlankState(players)
        
    for i in [0..10]
      
      playerId = players[i]
      
      player = @playersCollection.get(playerId)
      className = "assigned" if typeof(player) != "undefined"
      
      html += _.template @template, {
        player: @playersCollection.get(playerId)
        className: className
        playerNumber: i+1
      }    
    
    @$el.html html
    @$el.attr("class", @elevenModel.get("formation") )
      
    @makeDraggable()
    
    
    @
class App.SearchAutocompleteView extends Backbone.View
  
  className: "autocomplete"
  tagName: "ul"
  
  template: """
  <li data-id="<%= player.id %>" class="<%= className %>"><a href="#"><strong> <%= player.get("name") %> </strong> <em> <%= team.get("name") %> </em> </a> </li>
  """
  
  noResultsTemplate: """
    <li class="noResults">No players found. Are you sure you're a football fan?</li>
  """
  
  events:
    "click": "clickEvent"
    
  constructor: (settings) ->
    _.extend @, settings
    @bind()
    super
    
  bind: ->
    @on "keyup", @keyUpEvent
    @playersCollection = app.playersCollection
    @teamCollection = app.teamCollection
    @elevenModel = app.elevenModel
    
  clickEvent: (e) =>
    li = $(e.target).closest("li")
    playerId = li.data("id")
    @updatePlayer(playerId)
    @hide()
    
  updatePlayer: (id) ->
    @elevenModel.updatePlayer id
    @parent.clear()
    @render()
    
  keyUpEvent: (e) =>
    
    events = {
      13: "enter"
      40: "down"
      38: "up"
      27: "esc"
    }
    
    key = events[e.keyCode]
    selected = @$("li.selected")
    
    if key is "enter" and selected.length is 1
      @updatePlayer selected.data("id")
      @hide()
    else if key is "down" and selected.length is 1
    
      nextElem = selected.next()
      if nextElem.length is 1
        selected.removeClass("selected")
        nextElem.addClass("selected")
        
    else if key is "up" and selected.length is 1
    
      prevElem = selected.prev()
      if prevElem.length is 1
        selected.removeClass("selected")
        prevElem.addClass("selected")
        
    else if key is "esc" 
      @hide()
    else
      @value = @parent.getSearchValue()
      @render()

    
  hide: ->
    @$el.html ""
    
  render: =>
    
    value = @value
        
    if value is ""
      return @$el.html ""
            
    
    players = @playersCollection.search value
    
    playersSelected = @elevenModel.get("players")
    players = _.filter players, (player) ->
      _.indexOf(playersSelected,player.item.id) is -1 
    
    html = ""
        
    if players.length > 0
        
      for player,i in players
        
        team = @teamCollection.get player.item.get("team")
        
        html += _.template @template, {
          player: player.item
          team: team
          className: ("selected" if i is 0)
        } 
        
        if i is 5
          break  
        
    else 
     html = @noResultsTemplate
    
    @$el.html html    
    
    @
    
class App.SearchInputView extends Backbone.View

  el:"header form input"
  
  events:
    "keyup": "keyUpEvent"
  
  constructor: (settings) ->
    _.extend @, settings
    @bind()
    super
    
  keyUpEvent: (e) ->
    @autocompleteView.trigger "keyup", e
    e.preventDefault()
    
  bind: ->
    @autocompleteView = new App.SearchAutocompleteView {
      parent:@
    }
    @autocompleteView.$el.appendTo("body")
    $("form").submit (e) ->
      e.preventDefault()
    
  getSearchValue: ->
    @$el.val()
    
  clear:->
    @$el.val("")
    @$el.focus()
    
    
class App.ShareActionView extends Backbone.View
  
  shareOverlayTemplate: """
    <div class="pop share" style="display: block;">
    <span class="close"></span>
    <h2>Share your team</h2>
    <input type="text" value="<%= shareUrl %>" autofocus>
    </div>
  """

  el:"nav li a.share"
  
  events:
    "click": "clickEvent"
  
  constructor: (settings) ->
    _.extend @, settings
    @bind()
    super
    
  bind: ->
    @elevenModel = app.elevenModel
    @elevenModel.on "change change:players", @showButton
    $("body").on "click", ".pop.share .close", @hideShareOverlay
    
    if location.href.indexOf("?share") != -1
      @showShareOverlay()
    
  showShareOverlay: ->
    
    overlay = _.template @shareOverlayTemplate, {
      shareUrl: location.href.replace("?share", "")
    }
    
    $("body").append overlay
    
    
  hideShareOverlay: =>
    $("div.pop.share").remove()
    
  showButton: =>
    if @elevenModel._size(@elevenModel.get("players")) is 11
      @$el.addClass "enable"
      @$el.focus()
    else
      @$el.removeClass "enable"
    
  clickEvent:(e) =>
    e.preventDefault()
    @elevenModel.save null,
      success: (model, response) ->
        location.href = "/" + response.item._id + "?share"
    
    
