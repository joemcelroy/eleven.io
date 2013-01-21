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
    