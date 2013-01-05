# This module provides mongo database connections for crush.
#
mongoose = require 'mongoose'
exports.driver = mongoose.mongo
