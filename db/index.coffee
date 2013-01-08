# This module provides mongo database connections for crush.
#
mongoose = require 'mongoose'
pagination = require 'mongoose-pagination'

exports.driver = mongoose.mongo
