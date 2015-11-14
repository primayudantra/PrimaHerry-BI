var mongojs = require('mongojs')

var Schema = function(fields) {
  if (!fields) {
    fields = {};
  }
  var _this = this;
  // Store all defined fields in object instance
  Object.keys(fields).forEach(function(key) {
    _this[key] = fields[key];
  });
  // Always include the _id field
  this._id = mongojs.ObjectId
}

Schema.prototype.getFields = function() {
  return Object.keys(this);
}

Schema.prototype.addField = function(field, type) {
  this[field] = type;
}

module.exports = Schema;
