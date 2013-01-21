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
    
    