# This module provides mongo database connections for crush.
#
mongoose = require 'mongoose'
validator = require 'mongoose-validator'
pagination = require 'mongoose-pagination'


exports.driver = mongoose.mongo
exports.mongoose = mongoose
exports.ObjectId = mongoose.Schema.ObjectId
exports.Promise = mongoose.Promise
exports.validate = validator.validate
exports.validator = validator
