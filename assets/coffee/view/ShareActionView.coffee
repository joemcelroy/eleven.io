class App.ShareActionView extends Backbone.View
  
  shareOverlayTemplate: """
    <div class="pop share" style="display: block;">
    <span class="close"></span>
    <h2>Share your team</h2>
    <input type="text" value="<%= shareUrl %>" autofocus>
    </div>
  """

  el:"header form a.share"
  
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
    
    if location.href.indexOf("#share") != -1
      @showShareOverlay()
    
  showShareOverlay: ->
    
    overlay = _.template @shareOverlayTemplate, {
      shareUrl: location.href.replace("#share", "")
    }
    
    $("body").append overlay
    
    
  hideShareOverlay: =>
    $("div.pop.share").remove()
    location.href = location.href.replace("#share", "#")
    
  showButton: =>
    if @elevenModel.playersSize() is 11
      @$el.addClass "show"
      @$el.focus()
    else
      @$el.removeClass "show"
    
  clickEvent:(e) =>
    e.preventDefault()
    @elevenModel.save null,
      success: (model, response) ->
        location.href = "/" + response.item._id + "#share"
    
    
