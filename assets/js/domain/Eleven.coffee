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
    
     
    
    
    
    
     
    
  
  
  
  