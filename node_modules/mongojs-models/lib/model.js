var EventEmitter = require('events').EventEmitter;
var utils = require('./utils');
var _ = require('underscore');

module.exports = function(db) {
  return function(collection, schema) {
    var Collection = db.collection(collection);
    var Model = function (attributes) {
      if (!attributes) {
        attributes = {};
      }
      var _this = this;
      schema.getFields().forEach(function(attr) {
        if (attributes[attr] !== undefined) {
          _this[attr] = attributes[attr];
        }
      });
    }

    utils.extend(Model, Collection);

    // Save document to the collection
    Model.prototype.save = function(callback) {
      var _this = this;
      utils.waterfall(this, Model._hooks, function(err) {
        if (err) return callback.call(_this, err);
        _this.reset();
        Collection.save(_this, function(err, result) {
          Model.emit('save', result);
          callback.apply(_this, arguments);
        });
      });
    };

    // Register hooks to be called before saving a document
    Model._hooks = [];
    Model.preSave = function(fn) {
      Model._hooks.push(fn);
    };

    // Remove document from collection
    Model.prototype.remove = function(callback) {
      this.reset();
      var _this = this;
      Collection.remove(this, true, function(err, result) {
        Model.emit('remove', _this);
        callback(err, result && result.n === 1);
      });
    };

    Model.prototype._schema = schema;
    Model.prototype._fields = schema.getFields();

    // Remove attributes that are not part of the schema
    Model.prototype.reset = function() {
      var _this = this;
      _.keys(this).forEach(function(field) {
        if (_this._fields.indexOf(field) === -1) {
          delete _this[field];
        }
      });
    };

    // Return a pure JSON object with only schema fields
    Model.prototype.toJSON = function() {
      return _.pick(this, this._fields);
    };

    // Bind EventEmitter statically to the Model class
    Model._emitter = new EventEmitter();
    _.functions(Model._emitter).forEach(function(method) {
      Model[method] = Model._emitter[method];
    });

    // Inherit all collection prototype methods as static model methods
    _.functions(Collection).forEach(function(method) {
      Model[method] = Collection[method];
    });

    // Wrap methods that return documents
    ['find', 'findOne', 'insert', 'save', 'update'].forEach(function(method) {
      Model[method] = function() { return _apply(method, arguments); };
    });

    // Special cases
    Model.findAndModify = function() { return _apply('findAndModify', arguments, 'value'); };

    // Delegate function call to Collection instance
    var _apply = function(method, args, key) {
      var args = Array.prototype.slice.call(args);
      _wrapCallback(args, key);
      // Return control to original method
      Collection[method].apply(Collection, args);
    };

    // Wrap callback to return Model instances
    var _wrapCallback = function(args, key) {
      var _this = this;
      if (_.isFunction(_.last(args))) {
        callback = args.pop();
        args.push(function(err, result) {
          if (key) {
            result[key] = _mapResults(result[key]);
          } else {
            result = _mapResults(result);
          }
          callback.apply(_this, arguments);
        });
      }
    };

    // Convert result to Model instances
    var _mapResults = function(result) {
      if (!result) {
        return;
      }
      if (_.isArray(result)) {
        result = _.map(result, function(doc) {
          return new Model(doc);
        });
      } else {
        result = new Model(result);
      }
      return result;
    };

    return Model;
  };
};
