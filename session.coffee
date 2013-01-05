# This module provides session storage via connect-mongo.
#
express = require 'express'
mongostore = require('connect-mongo')(express)


# Function for constructing a new session storage.  The options parameter
# must include the app settings object, which must have a sessions object
# with a mongo url.
#
exports.storage = (options)->
  new mongostore url: options.settings.sessions.mongo
