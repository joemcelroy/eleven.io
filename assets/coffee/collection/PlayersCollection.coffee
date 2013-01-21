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