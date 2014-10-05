'use strict';

var mongoose = require('mongoose'),
    Schema = mongoose.Schema;

var CommentSchema = new Schema({
  _post: {type: Schema.Types.ObjectId, ref: 'Post'},
  _author: {type: Schema.Types.ObjectId, ref: 'Location'},
  content: String,
  date: { type: Date, default: Date.now },
  upvotes: [],
  downvotes: [],
});

CommentSchema
  .virtual('score')
  .get(function() {
    return this.upvotes.length - this.downvotes.length;
  })

module.exports = mongoose.model('Comment', CommentSchema);