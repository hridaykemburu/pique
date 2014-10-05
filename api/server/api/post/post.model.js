'use strict';

var mongoose = require('mongoose'),
    Schema = mongoose.Schema;

var PostSchema = new Schema({
  content: String,
  _author: { type: Schema.Types.ObjectId, ref: 'Phone'},
  _location: { type: Schema.Types.ObjectId, ref: 'Location'},
  upvotes: [],
  downvotes: [],
  date: { type: Date, default: Date.now }
});

PostSchema
  .virtual('score')
  .get(function() {
    return this.upvotes.length - this.downvotes.length;
  })

module.exports = mongoose.model('Post', PostSchema);