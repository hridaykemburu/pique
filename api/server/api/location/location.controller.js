'use strict';

var _ = require('lodash');
var Location = require('./location.model');
var Post = require('../post/post.model');

// Get list of locations
exports.index = function(req, res) {
  Location.find(function (err, locations) {
    if(err) { return handleError(res, err); }
    return res.json(200, locations);
  });
};

// Get a single location
exports.show = function(req, res) {
  Location.findById(req.params.id, function (err, location) {
    if(err) { return handleError(res, err); }
    if(!location) { return res.send(404); }
    getPosts(req.params.id, function(posts) {
      return res.json(200, _.extend(location.toObject(), {posts : posts}));
    }, function(err) {
      return handleError(res, err);
    })
  });
};

// Creates a new location in the DB.
exports.create = function(req, res) {
  Location.create(req.body, function(err, location) {
    if(err) { return handleError(res, err); }
    return res.json(201, location);
  });
};

// Updates an existing location in the DB.
exports.update = function(req, res) {
  if(req.body._id) { delete req.body._id; }
  Location.findById(req.params.id, function (err, location) {
    if (err) { return handleError(res, err); }
    if(!location) { return res.send(404); }
    var updated = _.merge(location, req.body);
    updated.save(function (err) {
      if (err) { return handleError(res, err); }
      return res.json(200, location);
    });
  });
};

// Deletes a location from the DB.
exports.destroy = function(req, res) {
  Location.findById(req.params.id, function (err, location) {
    if(err) { return handleError(res, err); }
    if(!location) { return res.send(404); }
    location.remove(function(err) {
      if(err) { return handleError(res, err); }
      return res.send(204);
    });
  });
};

function getPosts(id, success, error) {
  Post.find({"_location" : id}, function (err, posts) {
    if (err) { return error(err)}
    return success(posts);
  })
}

function handleError(res, err) {
  return res.send(500, err);
}