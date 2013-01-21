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