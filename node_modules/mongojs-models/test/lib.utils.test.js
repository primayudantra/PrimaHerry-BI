var expect = require('chai').expect;
var utils = require('../lib/utils.js');

describe('lib/utils.js', function() {
  it('should load all necessary objects', function() {
    expect(utils).to.contain.keys(['extend']);
    expect(utils.extend).to.be.a.function;
  });

  describe('.extend()', function() {
    it('should extend a child class from the instance of a parent class', function() {
      function Parent(foo) { this.foo = foo };
      function Child() {};
      utils.extend(Child, new Parent('bar'));
      expect(Child).to.contain.keys(['foo']);
      expect(Child.foo).to.equal('bar');
    });
  });

  describe('.waterfall()', function() {
    it('should run functions in order on the same object', function(done) {
      var doc = {};
      var tasks = [
        function(next) { doc.one = 1; next(); },
        function(next) { doc.two = 2; next(); },
        function(next) { doc.three = 3; next(); }
      ];
      utils.waterfall(doc, tasks, function(err, modifiedDoc) {
        if (err) return done(err);
        expect(modifiedDoc).to.be.ok;
        expect(modifiedDoc).to.equal(doc);
        expect(modifiedDoc).to.contain.keys(['one', 'two', 'three']);
        expect(modifiedDoc.one).to.equal(1);
        expect(modifiedDoc.two).to.equal(2);
        expect(modifiedDoc.three).to.equal(3);
        done();
      });
    });
  });
});
