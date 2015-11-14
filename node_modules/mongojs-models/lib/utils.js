var util = require('util');

module.exports = {};

// Extends a child class from the instance of a parent class
module.exports.extend = function(child, parent) {
  for (var key in parent) {
    if ({}.hasOwnProperty.call(parent, key)) {
      child[key] = parent[key];
    }
  }
  function ctor() {
    this.constructor = child;
  }
  if (parent) {
    ctor.prototype = parent.prototype;
    child.prototype = new ctor();
    child.__super__ = parent.prototype;
  }
  return child;
};

// Run asynchronous functions in order, binding every call to a document
module.exports.waterfall = function(doc, tasks, done) {
  tasks = tasks || [];
  done = done || function () {};
  if (!tasks.length) return done(null, doc);

  var wrapIterator = function (iterator) {
    return function (err) {
      if (err) {
        done.call(doc, err);
        done = function () {};
      } else {
        var callback = done;
        var next = iterator.next();
        if (next) callback = wrapIterator(next);
        process.nextTick(function () {
          iterator.call(doc, callback);
        });
      }
    };
  };

  var makeIterator = function (tasks) {
    var makeCallback = function (index) {
      var fn = function (next) {
        if (tasks.length) tasks[index].call(doc, function(err) {
          next(err, doc);
        });
        return fn.next();
      };
      fn.next = function () {
        return (index < tasks.length - 1) ? makeCallback(index + 1): null;
      };
      return fn;
    };
    return makeCallback(0);
  };

  wrapIterator(makeIterator(tasks))();
};
