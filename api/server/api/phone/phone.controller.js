'use strict';

var _ = require('lodash'),
    geolib = require('geolib');
var Phone = require('./phone.model');
var Post = require('../post/post.model');
var Location = require('../location/location.model');


// Get list of phones
exports.index = function(req, res) {
  Phone.find(function (err, phones) {
    if(err) { return handleError(res, err); }
    return res.json(200, phones);
  });
};

// Get a single phone
exports.show = function(req, res) {
  Phone.findById(req.params.id, function (err, phone) {
    if(err) { return handleError(res, err); }
    if(!phone) { return res.send(404); }
    return res.json(phone);
  });
};

// Creates a new phone in the DB.
exports.create = function(req, res) {
  Phone.create(req.body, function(err, phone) {
    if(err) { return handleError(res, err); }
    return res.json(201, phone);
  });
};

// Updates an existing phone in the DB.
exports.update = function(req, res) {
  if(req.body._id) { delete req.body._id; }
  Phone.findById(req.params.id, function (err, phone) {
    if (err) { return handleError(res, err); }
    if(!phone) { return res.send(404); }
    var updated = _.merge(phone, req.body);
    updateLocation(req.lat, req.lon);
    updated.save(function (err) {
      if (err) { return handleError(res, err); }
      return res.json(200, phone);
    });
  });
};

// Deletes a phone from the DB.
exports.destroy = function(req, res) {
  Phone.findById(req.params.id, function (err, phone) {
    if(err) { return handleError(res, err); }
    if(!phone) { return res.send(404); }
    phone.remove(function(err) {
      if(err) { return handleError(res, err); }
      return res.send(204);
    });
  });
};

exports.test = function(req, res) {
  updateLoction(1, 1, function(shortest) {
    return res.json(200, {one : shortest} );
  })
}

function getPosts(number, success, error) {
  Post.find({"_author" : number}, function (err, posts) {
    if (err) { return error(err)}
    return success(posts);
  })
}

function updateLoction(lat, lon, cb) {
  var latlng = {
    latitude: lat,
    longitude: lon
  };

  Location.find(function(err, locations) {
    if(err) { return handleError(res, err); }
    var orderedDistances = _.sortBy(locations, function(l) {
      return geolib.getDistance(latlng, l.latlng)
    });
    cb(orderedDistances[0]);
  })
}

function handleError(res, err) {
  return res.send(500, err);
}