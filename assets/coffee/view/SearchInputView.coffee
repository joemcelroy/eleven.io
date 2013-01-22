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
    
    @elevenModel = app.elevenModel
    @elevenModel.on "change change:players", @hideSearch
    
    @autocompleteView = new App.SearchAutocompleteView {
      parent:@
    }
    @autocompleteView.$el.appendTo("body")
    $("form").submit (e) ->
      e.preventDefault()
      
  hideSearch: =>
    if @elevenModel.playersSize() is 11
      @$el.addClass "hide"
    else
      @$el.removeClass "hide"
    
    
  getSearchValue: ->
    @$el.val()
    
  clear:->
    @$el.val("")
    @$el.focus()
    
    