var Eleven, ElevenSchema, app, assets, express, mongoUrl, mongoose, port, stylus, teams;

express = require('express');

stylus = require('stylus');

assets = require('connect-assets');

mongoose = require('mongoose');

mongoUrl = process.env.MONGOLAB_URI || 'localhost';

mongoose.connect(mongoUrl);

teams = {
  arsenal: {
    players: "1,2,3",
    formation: "four42"
  },
  chelsea: {
    players: "4,5,6",
    formation: "four43"
  }
};

ElevenSchema = mongoose.Schema({
  players: [Number],
  formation: "string"
});

Eleven = mongoose.model('Eleven', ElevenSchema);

app = express();

app.use(assets());

app.use(express.static(process.cwd() + '/public'));

app.configure(function() {
  app.use(express.bodyParser());
  return app.set('view engine', 'jade');
});

app.get('/', function(req, resp) {
  return resp.render('index', {
    players: "",
    formation: "four42"
  });
});

app.get('/:id', function(req, resp) {
  var id;
  id = req.params.id;
  if (teams[id] != null) {
    return resp.render('index', {
      players: teams[id].players,
      formation: teams[id].formation
    });
  } else {
    return Eleven.findById(req.params.id, function(err, record) {
      return resp.render('index', {
        players: record.players,
        formation: record.formation
      });
    });
  }
});

app.post('/eleven-api', function(req, resp) {
  var elevenItem;
  elevenItem = new Eleven(req.body);
  return elevenItem.save(function(err) {
    if (err) res.status(500);
    return resp.send({
      success: 'OK',
      item: elevenItem
    });
  });
});

port = process.env.PORT || process.env.VMC_APP_PORT || 3001;

app.listen(port, function() {
  return console.log("Listening on " + port + "\nPress CTRL-C to stop server.");
});
