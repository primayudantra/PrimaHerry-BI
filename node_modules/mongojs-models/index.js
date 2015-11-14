var mongojs = require('mongojs');
var Model = require('./lib/model');
var Schema = require('./lib/schema');

module.exports = function(config, collections) {
  var connect = mongojs(config, collections);
  connect.Model = Model(connect);
  connect.Schema = Schema;
  return connect;
}
