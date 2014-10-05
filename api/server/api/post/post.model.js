'use strict';

var mongoose = require('mongoose'),
    Schema = mongoose.Schema;

var PostSchema = new Schema({
  content: String,
  _author: { type: Schema.Types.ObjectId, ref: 'Phone'},
  _location: { type: Schema.Types.ObjectId, ref: 'Location'},
  upvotes: Number,
  downvotes: Number,
  date: Date
});

module.exports = mongoose.model('Post', PostSchema);