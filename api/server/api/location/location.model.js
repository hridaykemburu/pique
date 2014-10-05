'use strict';

var mongoose = require('mongoose'),
    Schema = mongoose.Schema;

var LocationSchema = new Schema({
  lat: Number,
  lon: Number,
  population: Number,
  name: String
});


LocationSchema
  .virtual('latlng')
  .get(function() {
    return {
      'latitude': this.lat,
      'longitude': this.lon
    };
  });

module.exports = mongoose.model('Location', LocationSchema);