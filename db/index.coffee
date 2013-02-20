# This module provides mongo database connections for crush.
#
mongoose = require 'mongoose'
#pagination = require 'mongoose-pagination'
#pagination.install mongoose

exports.driver = mongoose.mongo
exports.mongoose = mongoose
exports.ObjectId = mongoose.Schema.ObjectId
