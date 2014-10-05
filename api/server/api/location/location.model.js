'use strict';

var mongoose = require('mongoose'),
    Schema = mongoose.Schema;

var LocationSchema = new Schema({
  lat: Number,
  lon: Number,
  population: {type: Number, default: 0},
  name: String,
  googleId: String
});


LocationSchema
  .virtual('latlng')
  .get(function() {
    return {
      'latitude': this.lat,
      'longitude': this.lon
    };
  });


LocationSchema.methods = {

  checkIn: function(error) {
    this.population += 1;
    this.save(function(err) {
      if (err) { error(err); }
    });
  },

  checkOut: function(error) {
    this.population -= 1;
    this.save(function(err) {
      if (err) { error(err); }
    })
  }

}

module.exports = mongoose.model('Location', LocationSchema);