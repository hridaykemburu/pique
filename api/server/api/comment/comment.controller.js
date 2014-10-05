'use strict';

var _ = require('lodash');
var Comment = require('./comment.model');

// Get list of comments
exports.index = function(req, res) {
  Comment.find(function (err, comments) {
    if(err) { return handleError(res, err); }
    return res.json(200, comments);
  });
};

// Get a single comment
exports.show = function(req, res) {
  Comment.findById(req.params.id, function (err, comment) {
    if(err) { return handleError(res, err); }
    if(!comment) { return res.send(404); }
    return res.json(comment);
  });
};

// Creates a new comment in the DB.
exports.create = function(req, res) {
  Comment.create(req.body, function(err, comment) {
    if(err) { return handleError(res, err); }
    return res.json(201, comment);
  });
};

// Updates an existing comment in the DB.
exports.update = function(req, res) {
  if(req.body._id) { delete req.body._id; }
  Comment.findById(req.params.id, function (err, comment) {
    if (err) { return handleError(res, err); }
    if(!comment) { return res.send(404); }
    var updated = _.merge(comment, req.body);
    updated.save(function (err) {
      if (err) { return handleError(res, err); }
      return res.json(200, comment);
    });
  });
};

// Deletes a comment from the DB.
exports.destroy = function(req, res) {
  Comment.findById(req.params.id, function (err, comment) {
    if(err) { return handleError(res, err); }
    if(!comment) { return res.send(404); }
    comment.remove(function(err) {
      if(err) { return handleError(res, err); }
      return res.send(204);
    });
  });
};

exports.upvote = function(req, res) {
  Comment.findById(req.params.id, function (err, comment) {
    if(err) { return handleError(res, err); }
    if(!comment) { return res.send(404); }
    var uid = req.uid;
    var inDown = _.indexOf(comment.downvotes, uid)
    if (inDown > 0) {
      comment.downvotes.splice(inDown, 1);
    }
    comment.upvotes.push(uid);
    comment.upvotes = _.uniq(comment.upvotes);
    comment.save(function(err, comment) {
      if (err) { return handleError(res, err); }
      return res.json(200, comment);
    });
  });
};

exports.downvote = function(req, res) {
  Comment.findById(req.params.id, function (err, comment) {
    if(err) { return handleError(res, err); }
    if(!comment) { return res.send(404); }
    var uid = req.uid;
    var inUp = _.indexOf(comment.upvotes, uid)
    if (inUp > 0) {
      comment.downvotes.splice(inUp, 1);
    }
    comment.downvotes.push(uid);
    comment.downvotes = _.uniq(comment.downvotes);
    comment.save(function(err, comment) {
      if (err) { return handleError(res, err); }
      return res.json(200, comment);
    });
  });
};

function handleError(res, err) {
  return res.send(500, err);
}