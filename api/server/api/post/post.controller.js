'use strict';

var _ = require('lodash');
var Post = require('./post.model');
var Comment = require('../comment/comment.model');

// Get list of posts
exports.index = function(req, res) {
  Post.find(function (err, posts) {
    if(err) { return handleError(res, err); }
    return res.json(200, posts);
  });
};

// Get a single post
exports.show = function(req, res) {
  Post.findById(req.params.id, function (err, post) {
    if(err) { return handleError(res, err); }
    if(!post) { return res.send(404); }
    getComments(req.params.id, function(comments) {
      return res.json(_.extend(post.toObject(), {comments: comments || []}));
    }, function(err) {
      handleError(res, err);
    })
  });
};

// Creates a new post in the DB.
exports.create = function(req, res) {
  Post.create(req.body, function(err, post) {
    if(err) { return handleError(res, err); }
    return res.json(201, post);
  });
};

// Updates an existing post in the DB.
exports.update = function(req, res) {
  if(req.body._id) { delete req.body._id; }
  Post.findById(req.params.id, function (err, post) {
    if (err) { return handleError(res, err); }
    if(!post) { return res.send(404); }
    var updated = _.merge(post, req.body);
    updated.save(function (err) {
      if (err) { return handleError(res, err); }
      return res.json(200, post);
    });
  });
};

// Deletes a post from the DB.
exports.destroy = function(req, res) {
  Post.findById(req.params.id, function (err, post) {
    if(err) { return handleError(res, err); }
    if(!post) { return res.send(404); }
    post.remove(function(err) {
      if(err) { return handleError(res, err); }
      return res.send(204);
    });
  });
};

exports.upvote = function(req, res) {
  Post.findById(req.params.id, function (err, post) {
    if(err) { return handleError(res, err); }
    if(!post) { return res.send(404); }
    var uid = req.uid;
    var inDown = _.indexOf(post.downvotes, uid)
    if (inDown > 0) {
      post.downvotes.splice(inDown, 1);
    }
    post.upvotes.push(uid);
    post.upvotes = _.uniq(post.upvotes);
    post.save(function(err, post) {
      if (err) { return handleError(res, err); }
      return res.json(200, post);
    });
  });
};

exports.downvote = function(req, res) {
  Post.findById(req.params.id, function (err, post) {
    if(err) { return handleError(res, err); }
    if(!post) { return res.send(404); }
    var uid = req.uid;
    var inUp = _.indexOf(post.upvotes, uid)
    if (inUp > 0) {
      post.downvotes.splice(inUp, 1);
    }
    post.downvotes.push(uid);
    post.downvotes = _.uniq(post.downvotes);
    post.save(function(err, post) {
      if (err) { return handleError(res, err); }
      return res.json(200, post);
    });
  });
};

function getComments(id, success, error) {
  Comment.find({"_post" : id}, function (err, comments) {
    if (err) { return error(err)}
    return success(comments);
  })
}

function handleError(res, err) {
  return res.send(500, err);
}