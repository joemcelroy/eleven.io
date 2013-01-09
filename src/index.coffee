express = require 'express'
stylus = require 'stylus'
assets = require 'connect-assets'
mongoose = require 'mongoose'

mongoUrl = process.env.MONGOLAB_URI or 'localhost'
mongoose.connect mongoUrl

teams = {
  arsenal: {
    players: "1,2,3"
    formation:"four42"
  }
  chelsea: {
    players: "4,5,6"
    formation: "four43"
  }
}



ElevenSchema = mongoose.Schema { 
  players: [Number]
  formation: "string"
}

Eleven = mongoose.model 'Eleven', ElevenSchema;


app = express()
# Add Connect Assets
app.use assets()
# Set the public folder as static assets
app.use express.static(process.cwd() + '/public')

app.configure ->
  app.use express.bodyParser()
  app.set 'view engine', 'jade'



# Get root_path return index view
app.get '/', (req, resp) -> 
  resp.render 'index', {
    players: ""
    formation: "four42" 
  }
  
app.get '/:id', (req,resp) ->
  id = req.params.id
  
  if teams[id]?
    
    resp.render 'index', {
      players: teams[id].players
      formation: teams[id].formation 
    }
    
  else
    Eleven.findById req.params.id, (err, record) ->
      resp.render 'index', {
        players: record.players
        formation: record.formation 
      }

  
app.post '/eleven-api', (req,resp) ->
  elevenItem = new Eleven req.body
  
  elevenItem.save (err) ->
    if err
      res.status(500)
    
    resp.send({ success: 'OK', item: elevenItem })
    


# Define Port
port = process.env.PORT or process.env.VMC_APP_PORT or 3001
# Start Server
app.listen port, -> console.log "Listening on #{port}\nPress CTRL-C to stop server."