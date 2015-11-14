var expect = require('chai').expect;
var db = require('mongojs')('mongojs-test');
var Model = require('../lib/model.js')(db);
var Schema = require('../lib/schema.js');

var Test, test, _id;
describe('Model', function() {
  before(function() {
    // Create new Model class for `test.test`
    var schema = new Schema({foo: String, bar: Number});
    Test = new Model('test', schema);
  });

  it('should contain static collection methods', function() {
    expect(Test).to.contain.keys(['_name', 'find', 'findOne', 'save', 'remove']);
    expect(Test._name).to.equal('mongojs-test.test');
    expect(Test.find).to.be.a.function;
  });

  describe('static methods', function() {
    it('should save a new document to the collection', function(done) {
      Test.save({foo: 'foo', bar: 1}, function(err, test) {
        if (err) return done(err);
        expect(test).to.be.an.instanceof(Test);
        expect(test).to.contain.keys(['foo', 'bar', '_id']);
        expect(test.foo).to.equal('foo');
        expect(test.bar).to.equal(1);
        expect(test._id).to.be.an.instanceof(db.ObjectId);
        _id = test._id;
        done();
      });
    });

    it('should find document from the collection', function(done) {
      Test.findOne({_id: _id}, function(err, test) {
        if (err) return done(err);
        expect(test).to.be.an.instanceof(Test);
        expect(test).to.contain.keys(['foo', 'bar', '_id']);
        expect(test.foo).to.equal('foo');
        expect(test.bar).to.equal(1);
        expect(test._id).to.be.an.instanceof(db.ObjectId);
        done();
      });
    });

    it('should remove document from the collection', function(done) {
      Test.remove({_id: _id}, function(err, removed) {
        if (err) return done(err);
        expect(removed).to.have.keys('n');
        expect(removed.n).to.equal(1);
        done();
      });
    });
  });

  describe('prototype methods', function() {
    before(function() {
      test = new Test({foo: 'baz', bar: 2});
    });

    it('should save document to the collection', function(done) {
      test.save(function(err, sameTest) {
        if (err) return done(err);
        expect(sameTest).to.be.ok;
        expect(sameTest).to.equal(test);
        Test.findOne({_id: test._id}, function(err, foundTest) {
          if (err) return done(err);
          expect(foundTest).to.be.ok;
          expect(foundTest._id.toString()).to.equal(test._id.toString());
          done();
        });
      });
    });

    it('should only save fields defined in the schema', function(done) {
      test.baz = 'FOOBARBAZ';
      expect(test).to.contain.keys(['baz']);
      test.save(function(err, sameTest) {
        if (err) return done(err);
        expect(sameTest).to.be.ok;
        expect(sameTest).to.contain.keys(['foo', 'bar', '_id']);
        expect(sameTest).to.not.contain.keys(['baz']);
        expect(sameTest).to.equal(test);
        done();
      });
    });

    it('should remove document from the collection', function(done) {
      test.remove(function(err, removed) {
        if (err) return done(err);
        expect(removed).to.be.true;
        Test.findOne({_id: _id}, function(err, foundTest) {
          if (err) return (err);
          expect(foundTest).to.be.undefined;
          done();
        });
      });
    });
  });

  describe('events', function() {
    before(function() {
      test = new Test({foo: 'foobar', bar: 3});
    });

    it('should emit events', function(done) {
      Test.on('foo', function(foo) {
        expect(foo).to.equal('bar');
        done()
      });
      Test.emit('foo', 'bar');
    });

    it('should listen to a document being saved', function(done) {
      Test.once('save', function(doc) {
        expect(doc).to.equal(test);
        done();
      });
      test.save(function(err) {
        if (err) return done(err);
      });
    });

    it('should listen to a document being removed', function(done) {
      Test.on('remove', function(doc) {
        expect(doc).to.equal(test);
        done();
      });
      test.remove(function(err) {
        if (err) return done(err);
      });
    });
  });

  describe('pre-save', function() {
    before(function() {
      test = new Test({foo: 'foo', bar: 4});
    });

    it('should run asynchronous functions prior to saving a document', function(done) {
      Test.preSave(function(next) {
        this.foo = this.foo.toUpperCase();
        next();
      });
      Test.preSave(function(next) {
        this.foo = this.foo + 'bar';
        next();
      });
      test.save(function(err, afterSave) {
        if (err) return done(err);
        expect(afterSave).to.equal(test);
        expect(afterSave.foo).to.equal('FOObar');
        done();
      });
    });

    it('should fail to save on error callback', function(done) {
      Test.preSave(function(next) {
        next(new Error('You shall not pass'));
      });
      Test.preSave(function(next) {
        next(new Error('This should never be called'));
      });
      test.save(function(err, noSave) {
        expect(err).to.be.an.instanceof(Error);
        expect(err.message).to.equal('You shall not pass');
        expect(noSave).to.not.be.ok;
        done();
      });
    });
  });

  after(function(done) {
    db.dropDatabase(done);
  });
});
