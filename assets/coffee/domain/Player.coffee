class App.Player extends Backbone.Model

  getName: ->
    nameSplit = @get("name").split(" ")
    _.last nameSplit