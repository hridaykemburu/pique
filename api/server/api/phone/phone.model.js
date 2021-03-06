'use strict';

var mongoose = require('mongoose'),
    Schema = mongoose.Schema;

var PhoneSchema = new Schema({
  number: String,
  lat: Number,
  lon: Number,
  googleId: String,
  history: [{
    lat: Number,
    lon: Number,
    googleId: String,
    date: Date
  }]
});

module.exports = mongoose.model('Phone', PhoneSchema);