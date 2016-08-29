'use strict';

var express = require('express');
var app = express();
var path = require('path');

app.use('/src', express.static(path.join(__dirname, 'src')));
app.use('/content', express.static(path.join(__dirname, 'content')));
app.get('/', function(req, res){
  res.sendFile('index.html', {root: __dirname});
});
app.get('/bundle.js', function(req, res){
  res.sendFile('bundle.js', {root: __dirname});
});

var listener = app.listen(process.env.PORT || 3810, function(){
  console.log('listening on ', listener.address());
});
