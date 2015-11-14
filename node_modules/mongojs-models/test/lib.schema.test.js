var expect = require('chai').expect;
var Schema = require('../lib/schema.js');
var mongojs = require('mongojs');

var schema;
describe('Schema', function() {
  before(function() {
    schema = new Schema({
      foo: String,
      bar: Number
    });
  });

  it('should load all fields into its instance', function() {
    expect(schema).to.have.keys(['foo', 'bar', '_id']);
    expect(schema.foo).to.equal(String);
    expect(schema.bar).to.equal(Number);
    expect(schema._id).to.equal(mongojs.ObjectId);
  });

  describe('#getFields()', function() {
    it('should return a list of all defined fields', function() {
      var fields = schema.getFields();
      expect(fields).to.be.an.instanceof(Array);
      expect(fields).to.include.members(['foo', 'bar', '_id']);
    });
  });

  describe('#addField()', function() {
    it('should add fields to an existing schema', function() {
      schema.addField('baz', Boolean);
      expect(schema.getFields()).to.include.members(['foo', 'bar', '_id', 'baz']);
    });
  });
});
