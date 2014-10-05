'use strict';

var keys = require('../../config/local.env.js');
var _ = require('lodash'),
    geolib = require('geolib'),
    GooglePlaces = require('google-places'),
    places = new GooglePlaces(keys.PLACES_API_KEY);
var Location = require('./location.model');
var Post = require('../post/post.model');

// Get list of locations
exports.index = function(req, res) {
  var qParams = req.query;
  var lat = qParams.lat || 37.869846;
  var lon = qParams.lon || -122.266428;
  var term = qParams.term || null

  nearbyLocations(lat, lon, term, function(locations) {
    return res.json(200, locations);
  }, function(err) {
    handleError(res, err);
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

function nearbyLocations(lat, lon, term, success, error) {
  var latlng = {
    latitude: lat,
    longitude: lon
  };

  var query = {location: [lat, lon], radius: 2000};
  if (term) {
    query.keyword = term;
  }

  places.search(query, function(err, res) {
    var locations = [];
    var filtered = _.filter(res.results, function(r) {
      return !_.contains(r.types, 'political');
    })
    _.each(filtered, function(l) {
      var updates = {
        lat: l.geometry.location.lat,
        lon: l.geometry.location.lng,
        name: l.name,
        googleId: l.id
      };
      Location.findOneAndUpdate({googleId: l.id}, updates, {upsert: true}, function(err, location) {
        if (err) { return error(err); }
        locations.push(location);
        if (locations.length === filtered.length) {
          return success(_.sortBy(locations, function(l) {
            return geolib.getDistance(latlng, {latitude: l.lat, longitude: l.lon})
          }));
        }
      })
    })
  })
}

function handleError(res, err) {
  return res.send(500, err);
}