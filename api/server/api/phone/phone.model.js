'use strict';

var mongoose = require('mongoose'),
    Schema = mongoose.Schema;

var PhoneSchema = new Schema({
  number: String,
  lat: Number,
  lon: Number
});

module.exports = mongoose.model('Phone', PhoneSchema);