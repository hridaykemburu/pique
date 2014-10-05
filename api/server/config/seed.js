/**
 * Populate DB with sample data on server start
 * to disable, edit config/environment/index.js, and set `seedDB: false`
 */

'use strict';

var Thing = require('../api/thing/thing.model');
var User = require('../api/user/user.model');
var Phone = require('../api/phone/phone.model');
var Location = require('../api/location/location.model');
var Post = require('../api/post/post.model');
var Comment = require('../api/comment/comment.model');

var phones;
Phone.find({}).remove(function() {
  Phone.create([{
    number: '4102222222'
  }, {
    number: '4101111111'
  }, {
    number: '1234567890'
  }], function(err, p1, p2, p3) {
    phones = [p1, p2, p3];
    done()
  })
});

var locs;
Location.find({}).remove(function() {
  Location.create({
    lat: 37.869846,
    lon: -122.266428,
    population: 0,
    name: 'Allston Lofts',
    googleId: '1'
  }, {
    lat: 39.474686,
    lon: -87.366960,
    population: 1000,
    name: 'Memorial Stadium',
    googleId: '123'
  }, {
    lat: 37.774610,
    lon: -122.455754,
    population: 3,
    name: 'The House',
    googleId: 'jah'
  }, function(err, l1, l2, l3) {
    locs = [l1, l2, l3];
    done()
  })
})

var posts;
function done() {
  if (phones && phones.length > 0 && locs && locs.length > 0) {
    Post.find({}).remove(function() {
      Post.create({
        content: 'Interesting post',
        _author: phones[0]._id,
        _location: locs[1]._id,
        upvotes: [phones[1]._id, phones[2]._id],
        downvotes: [phones[0]._id]
      }, {
        content: 'Interesting post',
        _author: phones[1]._id,
        _location: locs[2]._id,
        upvotes: [phones[0]._id],
        downvotes: [phones[1]._id, phones[2]._id],
      }, function(err, p1, p2) {
        posts = [p1, p2];
        makeComments();
      })
    });
  }
}

function makeComments() {
  Comment.find({}).remove(function() {
    Comment.create({
      content: 'Interesting comment',
      _post: posts[0]._id,
      _author: phones[0]._id,
      upvotes: [phones[1]._id, phones[2]._id],
      downvotes: [phones[0]._id]
    }, {
      content: 'Interesting comment',
      _post: posts[1]._id,
      _author: phones[1]._id,
      upvotes: [phones[0]._id, phones[1]._id],
      downvotes: [phones[2]._id]
    })
  })
}

Thing.find({}).remove(function() {
  Thing.create({
    name : 'Development Tools',
    info : 'Integration with popular tools such as Bower, Grunt, Karma, Mocha, JSHint, Node Inspector, Livereload, Protractor, Jade, Stylus, Sass, CoffeeScript, and Less.'
  }, {
    name : 'Server and Client integration',
    info : 'Built with a powerful and fun stack: MongoDB, Express, AngularJS, and Node.'
  }, {
    name : 'Smart Build System',
    info : 'Build system ignores `spec` files, allowing you to keep tests alongside code. Automatic injection of scripts and styles into your index.html'
  },  {
    name : 'Modular Structure',
    info : 'Best practice client and server structures allow for more code reusability and maximum scalability'
  },  {
    name : 'Optimized Build',
    info : 'Build process packs up your templates as a single JavaScript payload, minifies your scripts/css/images, and rewrites asset names for caching.'
  },{
    name : 'Deployment Ready',
    info : 'Easily deploy your app to Heroku or Openshift with the heroku and openshift subgenerators'
  });
});

User.find({}).remove(function() {
  User.create({
    provider: 'local',
    name: 'Test User',
    email: 'test@test.com',
    password: 'test'
  }, {
    provider: 'local',
    role: 'admin',
    name: 'Admin',
    email: 'admin@admin.com',
    password: 'admin'
  }, function() {
      console.log('finished populating users');
    }
  );
});