class App.FormationSelectView extends Backbone.View

  el:"select"
  
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
    
