'use strict';

var config = require('../../config/environment');
var _ = require('lodash'),
    geolib = require('geolib'),
    GooglePlaces = require('google-places'),
    places = new GooglePlaces(config.secrets.PLACES_API),
    request = require('request');
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
    getPosts(req.params.id, function(posts) {
      return res.json(200, _.extend(phone.toObject(), {posts: posts}));
    }, function(err) {
      return handleError(res, err);
    })
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
    updated.save(function (err) {
      if (err) { return handleError(res, err); }
      return res.json(200, phone);
    });
  });
};

exports.updateLocation = function(req, res) {
  Phone.findById(req.params.id, function (err, phone) {
    if (err) { return handleError(res, err); }
    if (!phone) { return res.send(404); }
    var now = Date();
    var oldLatLng = {
      lat: phone.lat,
      lon: phone.lon,
      date: now,
      googleId: phone.googleId
    }
    phone.history.push(oldLatLng);
    phone.lat = req.body.lat;
    phone.lon = req.body.lon;
    updateLocation(phone, oldLatLng);
    phone.save(function(err, phone) {
      if (err) { return handleError(res, err); }
      return res.json(200, phone);
    })
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
  updateLocation(41.53481, -75.736349);
  return res.json(200, {});
}

function getPosts(id, success, error) {
  Post.find({"_author" : id}, function (err, posts) {
    if (err) { return error(err)}
    return success(posts);
  })
}

function updateLocation(phone, old, success, error) {
  var lat = phone.lat;
  var lon = phone.lon;
  var latlng = {
    latitude: lat,
    longitude: lon
  };

  var query = {
    proxy: process.env.QUOTAGUARDSTATIC_URL,
    url: 'https://maps.googleapis.com/maps/api/place/nearbysearch/json',
    json: true,
    qs: {
      key: config.secrets.PLACES_API,
      location: [lat, lon].join(','),
      radius: 20
    },
    headers: {
      'User-Agent': 'node.js'
    }
  };

  request(query, function(err, res, body) {
    var filtered = _.filter(body.results, function(r) {
      return !_.contains(r.types, 'political');
    });

    var locations = _.sortBy(filtered, function(l) {
      var locationLatLng = {
        latitude: l.geometry.location.lat,
        longitude: l.geometry.location.lng
      }
      return geolib.getDistance(latlng, locationLatLng)
    });

    var nearest = locations[0];
    if (!nearest) { return; }
    var nearestLatLon = {
      latitude: nearest.geometry.location.lat,
      longitude: nearest.geometry.location.lng,
    }
    if (!old.googleId && geolib.getDistance(latlng, nearestLatLon) > 40) { return; } //not in a place
    if (old.googleId === nearest.id) { return; } //in same place as before
    if (old.googleId) { //check out of old place if it is not current place
      Location.findOne({googleId: old.googleId}, function(err, location) {
        if (err) { return error(err); }
        if (!location) { return; }
        location.checkOut(function(err) {
          if (err) {
            return error(err);
          }
        })
      })
    }

    Location.findOne({googleId: nearest.id}, function(err, location) {
      if (err) { return error(err); }
      phone.googleId = nearest.id;
      phone.save(function(err) {
        if (err) { return error(err); }
      })
      if (!location) {
        var newLoc = {
          lat: nearest.geometry.location.lat,
          lon: nearest.geometry.location.lng,
          population: 1,
          name: nearest.name,
          googleId: nearest.id
        }
        Location.create(newLoc, function(err, location) {
          console.log(location);
          if (err) { return error(err) }
        });
      } else {
        location.checkIn(function(err) {
          if (err) {
            return error(err);
          }
        })
      }
    })
  })
}

function handleError(res, err) {
  return res.send(500, err);
}